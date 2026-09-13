import ballerina/io;

RentalAccommodationServiceClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    AddPropertyRequest addPropertyRequest = {property_name: "Ocean View Apartment", location: "Swakopmund", property_type: "Apartment", price_per_night: 1200, status: "AVAILABLE"};
    AddPropertyResponse addPropertyResponse = check ep->AddProperty(addPropertyRequest);
    io:println(addPropertyResponse);

    UpdatePropertyRequest updatePropertyRequest = {property_id: addPropertyResponse.property_id, property_name: "Ocean View Apartment", location: "Swakopmund", property_type: "Apartment", price_per_night: 1350, status: "AVAILABLE"};
    UpdatePropertyResponse updatePropertyResponse = check ep->UpdateProperty(updatePropertyRequest);
    io:println(updatePropertyResponse);

    UserProfile host = {user_id: "HOST-001", full_name: "Amara Ndlovu", email: "amara@example.com", role: "HOST"};
    UserProfile guest = {user_id: "GUEST-001", full_name: "Lukas Smith", email: "lukas@example.com", role: "GUEST"};
    CreateUsersStreamingClient createUsersStreamingClient = check ep->CreateUsers();
    check createUsersStreamingClient->sendUserProfile(host);
    check createUsersStreamingClient->sendUserProfile(guest);
    check createUsersStreamingClient->complete();
    CreateUsersResponse? createUsersResponse = check createUsersStreamingClient->receiveCreateUsersResponse();
    io:println(createUsersResponse);

    ListPropertiesRequest listPropertiesRequest = {};
    stream<Property, error?> listPropertiesResponse = check ep->ListProperties(listPropertiesRequest);
    check listPropertiesResponse.forEach(function(Property value) {
        io:println(value);
    });

        SearchPropertyRequest searchPropertyRequest = {property_id: addPropertyResponse.property_id};
    SearchPropertyResponse searchPropertyResponse = check ep->SearchProperty(searchPropertyRequest);
    io:println(searchPropertyResponse);

    BookPropertyRequest bookPropertyRequest = {property_id: addPropertyResponse.property_id, guest_id: "GUEST-001", check_in: "2026-10-01", check_out: "2026-10-05"};
    BookPropertyResponse bookPropertyResponse = check ep->BookProperty(bookPropertyRequest);
    io:println(bookPropertyResponse);

    ConfirmBookingRequest confirmBookingRequest = {booking_request_id: bookPropertyResponse.booking_request_id};
    ConfirmBookingResponse confirmBookingResponse = check ep->ConfirmBooking(confirmBookingRequest);
    io:println(confirmBookingResponse);

    RemovePropertyRequest removePropertyRequest = {property_id: addPropertyResponse.property_id, host_id: "HOST-001"};
    RemovePropertyResponse removePropertyResponse = check ep->RemoveProperty(removePropertyRequest);
    io:println(removePropertyResponse);
}

