import ballerina/grpc;
import ballerina/time;
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

remote function BookProperty(BookPropertyRequest value) returns BookPropertyResponse|error {
    lock {
    

        if value.check_out <= value.check_in {
            return {success: false, message: "Check-out must be after check-in", booking_request_id: ""};
        }

        string bookingId = "CART-" + nextBookingId.toString();
        nextBookingId += 1;
        bookingCart[bookingId] = value;

        return {success: true, message: "Added to booking cart", booking_request_id: bookingId};
    }
}

remote function ConfirmBooking(ConfirmBookingRequest value) returns ConfirmBookingResponse|error {
    lock {
        if !bookingCart.hasKey(value.booking_request_id) {
            return {success: false, message: "Booking request not found", booking_id: "", total_cost: 0.0};
        }

        BookPropertyRequest cartEntry = bookingCart.get(value.booking_request_id);
        Property target = properties.get(cartEntry.property_id);

        time:Utc ciUtc = check time:utcFromString(cartEntry.check_in + "T00:00:00.00Z");
        time:Utc coUtc = check time:utcFromString(cartEntry.check_out + "T00:00:00.00Z");

        int nights = <int>(coUtc[0] - ciUtc[0]) / 86400;
        float totalCost = <float>nights * target.price_per_night;

        string bookingId = "BOOK-" + nextBookingId.toString();
        nextBookingId += 1;

        ConfirmBookingResponse response = {
            success: true,
            message: "Booking confirmed",
            booking_id: bookingId,
            total_cost: totalCost
        };

        confirmedBookings[bookingId] = response;
        _ = bookingCart.remove(value.booking_request_id);

        return response;
    }
}
}
