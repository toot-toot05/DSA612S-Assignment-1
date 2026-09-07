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
    Property? target = getProperty(value.property_id);
    if target is () {
        return {success: false, message: "Not found", remaining_properties: []};
    }
    if target.host_id != value.host_id {
        return {success: false, message: "Not authorized", remaining_properties: []};
    }
    deleteProperty(value.property_id);
    Property[] remaining = getPropertiesByRegion(target.location);
    return {success: true, message: "Removed", remaining_properties: remaining};
}

remote function SearchProperty(SearchPropertyRequest value) returns SearchPropertyResponse|error {
    Property? found = getProperty(value.property_id);
    if found is () {
        return {found: false, property: {}, status_mesg: "Not Available"};
    }
    return {found: true, property: found, status_mesg: "Found"};
}
}
