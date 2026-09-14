import ballerina/io;

RentalAccommodationServiceClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    while true {
        io:println("\n========================================");
        io:println(" RENTAL ACCOMMODATION SYSTEM");
        io:println("========================================");
        io:println("1. Add Property");
        io:println("2. Update Property");
        io:println("3. List Properties");
        io:println("4. Search Property");
        io:println("5. Book Property");
        io:println("6. Confirm Booking");
        io:println("7. Remove Property");
        io:println("8. Create Users");
        io:println("9. Exit");
        io:println("========================================");

        string choice = io:readln("Choose an option: ");

        match choice {
            "1" => {
                error? result = addProperty();
                handleError(result);
            }
            "2" => {
                error? result = updateProperty();
                handleError(result);
            }
            "3" => {
                error? result = listProperties();
                handleError(result);
            }
            "4" => {
                error? result = searchProperty();
                handleError(result);
            }
            "5" => {
                error? result = bookProperty();
                handleError(result);
            }
            "6" => {
                error? result = confirmBooking();
                handleError(result);
            }
            "7" => {
                error? result = removeProperty();
                handleError(result);
            }
            "8" => {
                error? result = createUsers();
                handleError(result);
            }
            "9" => {
                io:println("\nThank you for using the Rental Accommodation System.");
                return;
            }
            _ => {
                io:println("\nInvalid option. Please choose between 1 and 9.");
            }
        }

        io:println("\nPress Enter to return to the main menu...");
        string pause = io:readln();
    }
}

function handleError(error? result) {
    if result is error {
        io:println("\nERROR: ", result.message());
    }
}

function addProperty() returns error? {
    io:println("\n========== ADD PROPERTY ==========");

    string propertyName = io:readln("Property name: ");
    string location = io:readln("Location: ");
    string propertyType = io:readln("Property type: ");
    float price = check float:fromString(io:readln("Price per night: "));
    string status = io:readln("Status: ");

    AddPropertyResponse response = check ep->AddProperty({
        property_name: propertyName,
        location: location,
        property_type: propertyType,
        price_per_night: price,
        status: status
    });

    io:println("\n========== RESULT ==========");
    io:println("Property ID: ", response.property_id);
    io:println("Message: ", response.message);
}

function updateProperty() returns error? {
    io:println("\n========== UPDATE PROPERTY ==========");

    string propertyId = io:readln("Property ID: ");
    string propertyName = io:readln("New property name: ");
    string location = io:readln("New location: ");
    string propertyType = io:readln("New property type: ");
    float price = check float:fromString(io:readln("New price per night: "));
    string status = io:readln("New status: ");

    UpdatePropertyResponse response = check ep->UpdateProperty({
        property_id: propertyId,
        property_name: propertyName,
        location: location,
        property_type: propertyType,
        price_per_night: price,
        status: status
    });

    io:println("\n========== RESULT ==========");
    io:println("Updated: ", response.updated);
    io:println("Message: ", response.message);

    if response.updated {
        io:println("Property: ", response.property);
    }
}

function listProperties() returns error? {
    io:println("\n========== LIST PROPERTIES ==========");

    string location = io:readln("Location (press Enter for all): ");
    string propertyType = io:readln("Property type (press Enter for all): ");

    stream<Property, error?> properties = check ep->ListProperties({
        location: location,
        property_type: propertyType
    });

    boolean found = false;

    check properties.forEach(function(Property property) {
        found = true;

        io:println("\n----------------------------------------");
        io:println("Property ID: ", property.property_id);
        io:println("Name: ", property.property_name);
        io:println("Location: ", property.location);
        io:println("Type: ", property.property_type);
        io:println("Price per night: ", property.price_per_night);
        io:println("Status: ", property.status);
    });

    if !found {
        io:println("\nNo properties found.");
    }
}

function searchProperty() returns error? {
    io:println("\n========== SEARCH PROPERTY ==========");

    SearchPropertyResponse response = check ep->SearchProperty({
        property_id: io:readln("Property ID: ")
    });

    if response.found {
        io:println("\n========== PROPERTY FOUND ==========");
        io:println("Property ID: ", response.property.property_id);
        io:println("Name: ", response.property.property_name);
        io:println("Location: ", response.property.location);
        io:println("Type: ", response.property.property_type);
        io:println("Price per night: ", response.property.price_per_night);
        io:println("Status: ", response.property.status);
    } else {
        io:println("\nProperty not found.");
        io:println("Message: ", response.status_mesg);
    }
}

function bookProperty() returns error? {
    io:println("\n========== BOOK PROPERTY ==========");

    BookPropertyResponse response = check ep->BookProperty({
        property_id: io:readln("Property ID: "),
        guest_id: io:readln("Guest ID: "),
        check_in: io:readln("Check-in date (YYYY-MM-DD): "),
        check_out: io:readln("Check-out date (YYYY-MM-DD): ")
    });

    io:println("\n========== BOOKING RESULT ==========");
    io:println("Success: ", response.success);
    io:println("Message: ", response.message);

    if response.success {
        io:println("Booking Request ID: ", response.booking_request_id);
    }
}

function confirmBooking() returns error? {
    io:println("\n========== CONFIRM BOOKING ==========");

    ConfirmBookingResponse response = check ep->ConfirmBooking({
        booking_request_id: io:readln("Booking Request ID: ")
    });

    io:println("\n========== CONFIRMATION RESULT ==========");
    io:println("Success: ", response.success);
    io:println("Message: ", response.message);

    if response.success {
        io:println("Booking ID: ", response.booking_id);
        io:println("Total cost: ", response.total_cost);
    }
}

function removeProperty() returns error? {
    io:println("\n========== REMOVE PROPERTY ==========");

    RemovePropertyResponse response = check ep->RemoveProperty({
        property_id: io:readln("Property ID: "),
        host_id: io:readln("Host ID: ")
    });

    io:println("\n========== REMOVE RESULT ==========");
    io:println("Success: ", response.success);
    io:println("Message: ", response.message);

    if response.success {
        io:println("\nRemaining properties:");

        foreach Property property in response.remaining_properties {
            io:println(
                property.property_id,
                " | ",
                property.property_name,
                " | ",
                property.location
            );
        }
    }
}

function createUsers() returns error? {
    io:println("\n========== CREATE USERS ==========");

    CreateUsersStreamingClient streamClient = check ep->CreateUsers();

    while true {
        io:println("\nEnter user information:");

        UserProfile user = {
            user_id: io:readln("User ID: "),
            full_name: io:readln("Full name: "),
            email: io:readln("Email: "),
            role: io:readln("Role (HOST/GUEST): ")
        };

        check streamClient->sendUserProfile(user);

        string another = io:readln("Add another user? (y/n): ");

        if another.toLowerAscii() != "y" {
            break;
        }
    }

    check streamClient->complete();

    CreateUsersResponse? response =
        check streamClient->receiveCreateUsersResponse();

    io:println("\n========== RESULT ==========");

    if response is CreateUsersResponse {
        io:println("Users created: ", response.users_created);
        io:println("Message: ", response.message);
    } else {
        io:println("No response received.");
    }
}