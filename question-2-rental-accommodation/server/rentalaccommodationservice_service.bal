import ballerina/grpc;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
service "RentalAccommodationService" on ep {

    remote function AddProperty(AddPropertyRequest value) returns AddPropertyResponse|error {
        string propertyId = saveProperty(value);
        return {
            property_id: propertyId,
            message: "Property added successfully"
        };
    }

    remote function UpdateProperty(UpdatePropertyRequest value) returns UpdatePropertyResponse|error {
        Property? updated = updateStoredProperty(value);
        if updated is () {
            return {
                updated: false,
                message: "Property not found"
            };
        }
        return {
            updated: true,
            message: "Property updated successfully",
            property: updated
        };
    }

    remote function CreateUsers(stream<UserProfile, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        int count = 0;
        record {|UserProfile value;|}|grpc:Error? next = clientStream.next();
        while next is record {|UserProfile value;|} {
            registerUser(next.value);
            count += 1;
            next = clientStream.next();
        }
        if next is grpc:Error {
            return next;
        }
        return {
            users_created: count,
            message: "Users registered successfully"
        };
    }

    remote function ListProperties(ListPropertiesRequest value) returns stream<Property, error?>|error {
        return matchingProperties(value).toStream();
    }

remote function RemoveProperty(RemovePropertyRequest value) returns RemovePropertyResponse|error {
    lock {
        if !properties.hasKey(value.property_id) {
            return {success: false, message: "Not found", remaining_properties: []};
        }
        Property target = properties.get(value.property_id);
        _ = properties.remove(value.property_id);

        Property[] remaining = [];
        foreach Property p in properties {
            if p.location == target.location {
                remaining.push(p);
            }
        }
        return {success: true, message: "Removed", remaining_properties: remaining};
    }
}

remote function SearchProperty(SearchPropertyRequest value) returns SearchPropertyResponse|error {
    lock {
        if !properties.hasKey(value.property_id) {
            return {found: false, property: {}, status_mesg: "Not Available"};
        }
        return {found: true, property: properties.get(value.property_id), status_mesg: "Found"};
    }
}
}
