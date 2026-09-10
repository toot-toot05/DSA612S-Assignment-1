import ballerina/http;
import ballerina/io;

type Component record {|
    string compId;
    string name;
    string description;
|};

type Schedule record {|
    string scheduleId;
    string scheduleType;
    string dueDate;
    string startDate = "";
    string endDate = "";
    string description;
|};

type Task record {|
    string taskId;
    string description;
|};

type WorkOrder record {|
    string orderId;
    string status;
    string description;
    Task[] tasks;
|};

type Asset record {|
    string assetTag;
    string name;
    string description;
    string institution;
    string site;
    string status;
    string dateAcquired;
    Component[] components;
    Schedule[] schedules;
    WorkOrder[] workOrders;
|};

http:Client backend = check new ("http://localhost:8080");

public function main() returns error? {

    while true {
        io:println("");
        io:println("==========================================");
        io:println("       LIBRARY MANAGEMENT SYSTEM");
        io:println("==========================================");
        io:println("1. Global Asset View");
        io:println("2. Campus / Institution View");
        io:println("3. Loan / Return");
        io:println("4. Booking");
        io:println("5. Overdue Dashboard");
        io:println("6. Schedule Manager");
        io:println("7. Exit");
        io:println("==========================================");
        io:print("Select an option: ");

        string|error input = io:readln();

        if input is error {
            io:println("Unable to read input.");
            continue;
        }

        match input.trim() {
            "1" => {
                check globalAssetView();
            }
            "2" => {
                check campusView();
            }
            "3" => {
                check loanReturnMenu();
            }
            "4" => {
                check bookingMenu();
            }
            "5" => {
                io:println("");
                io:println("Overdue Dashboard functionality coming next.");
            }
            "6" => {
                io:println("");
                io:println("Schedule Manager functionality coming next.");
            }
            "7" => {
                io:println("");
                io:println("Exiting Library Management System...");
                break;
            }
            _ => {
                io:println("Invalid option. Please select 1-7.");
            }
        }
    }
}


// ==========================================
// GLOBAL ASSET VIEW
// ==========================================

function globalAssetView() returns error? {

    io:println("");
    io:println("============= GLOBAL ASSET VIEW =============");

    Asset[] assets = check backend->get("/api/assets");

    if assets.length() == 0 {
        io:println("No assets found.");
        return;
    }

    foreach Asset asset in assets {
        displayAsset(asset);
    }

    io:println("---------------------------------------------");
    io:println("Total assets: ", assets.length());
}


// ==========================================
// CAMPUS / INSTITUTION VIEW
// ==========================================

function campusView() returns error? {

    while true {
        io:println("");
        io:println("============= CAMPUS / INSTITUTION VIEW =============");
        io:println("1. View by Institution");
        io:println("2. View by Site");
        io:println("3. Back");
        io:println("======================================================");
        io:print("Select an option: ");

        string|error input = io:readln();

        if input is error {
            io:println("Unable to read input.");
            continue;
        }

        match input.trim() {
            "1" => {
                check viewByInstitution();
            }
            "2" => {
                check viewBySite();
            }
            "3" => {
                break;
            }
            _ => {
                io:println("Invalid option.");
            }
        }
    }
}


// ==========================================
// VIEW BY INSTITUTION
// ==========================================

function viewByInstitution() returns error? {

    io:println("");
    io:print("Enter institution name: ");

    string|error input = io:readln();

    if input is error {
        io:println("Unable to read institution.");
        return;
    }

    string institution = input.trim();

    if institution == "" {
        io:println("Institution name cannot be empty.");
        return;
    }

    string path = "/api/assets/institution/" + institution;

    Asset[] assets = check backend->get(path);

    io:println("");
    io:println("============= INSTITUTION ASSETS =============");

    if assets.length() == 0 {
        io:println("No assets found for this institution.");
        return;
    }

    foreach Asset asset in assets {
        displayAsset(asset);
    }

    io:println("---------------------------------------------");
    io:println("Total assets: ", assets.length());
}


// ==========================================
// VIEW BY SITE
// ==========================================

function viewBySite() returns error? {

    io:println("");
    io:print("Enter institution name: ");

    string|error institutionInput = io:readln();

    if institutionInput is error {
        io:println("Unable to read institution.");
        return;
    }

    string institution = institutionInput.trim();

    if institution == "" {
        io:println("Institution name cannot be empty.");
        return;
    }

    io:print("Enter site name: ");

    string|error siteInput = io:readln();

    if siteInput is error {
        io:println("Unable to read site.");
        return;
    }

    string site = siteInput.trim();

    if site == "" {
        io:println("Site name cannot be empty.");
        return;
    }

    string path =
        "/api/assets/institution/" + institution + "/site/" + site;

    Asset[] assets = check backend->get(path);

    io:println("");
    io:println("============= SITE ASSETS =============");

    if assets.length() == 0 {
        io:println("No assets found for this site.");
        return;
    }

    foreach Asset asset in assets {
        displayAsset(asset);
    }

    io:println("---------------------------------------");
    io:println("Total assets: ", assets.length());
}


// ==========================================
// LOAN / RETURN MENU
// ==========================================

function loanReturnMenu() returns error? {

    while true {
        io:println("");
        io:println("============= LOAN / RETURN =============");
        io:println("1. Loan an Asset");
        io:println("2. Return an Asset");
        io:println("3. Back");
        io:println("==========================================");
        io:print("Select an option: ");

        string|error input = io:readln();

        if input is error {
            io:println("Unable to read input.");
            continue;
        }

        match input.trim() {
            "1" => {
                check loanAsset();
            }
            "2" => {
                check returnAsset();
            }
            "3" => {
                break;
            }
            _ => {
                io:println("Invalid option.");
            }
        }
    }
}


// ==========================================
// LOAN ASSET
// ==========================================

function loanAsset() returns error? {

    io:println("");
    io:print("Enter asset tag to loan: ");

    string|error input = io:readln();

    if input is error {
        io:println("Unable to read asset tag.");
        return;
    }

    string assetTag = input.trim();

    if assetTag == "" {
        io:println("Asset tag cannot be empty.");
        return;
    }

    string path = "/api/assets/" + assetTag + "/loan";

    http:Response response = check backend->post(path, ());

    io:println("");

    if response.statusCode == 201 {
        io:println("Asset successfully loaned.");

        json|error payload = response.getJsonPayload();

        if payload is json {
            Asset|error asset = payload.cloneWithType();

            if asset is Asset {
                displayAsset(asset);
            }
        }
    } else {
        io:println("Unable to loan asset.");
        io:println("HTTP Status: ", response.statusCode);

        string|error body = response.getTextPayload();

        if body is string {
            io:println("Message: ", body);
        }
    }
}


// ==========================================
// RETURN ASSET
// ==========================================

function returnAsset() returns error? {

    io:println("");
    io:print("Enter asset tag to return: ");

    string|error input = io:readln();

    if input is error {
        io:println("Unable to read asset tag.");
        return;
    }

    string assetTag = input.trim();

    if assetTag == "" {
        io:println("Asset tag cannot be empty.");
        return;
    }

    string path = "/api/assets/" + assetTag + "/return";

    http:Response response = check backend->post(path, ());

    io:println("");

    if response.statusCode == 201 {
        io:println("Asset successfully returned.");

        json|error payload = response.getJsonPayload();

        if payload is json {
            Asset|error asset = payload.cloneWithType();

            if asset is Asset {
                displayAsset(asset);
            }
        }
    } else {
        io:println("Unable to return asset.");
        io:println("HTTP Status: ", response.statusCode);

        string|error body = response.getTextPayload();

        if body is string {
            io:println("Message: ", body);
        }
    }
}


// ==========================================
// DISPLAY ASSET
// ==========================================

function displayAsset(Asset asset) {

    io:println("");
    io:println("Asset Tag:    ", asset.assetTag);
    io:println("Name:         ", asset.name);
    io:println("Institution:  ", asset.institution);
    io:println("Site:         ", asset.site);
    io:println("Status:       ", asset.status);
    io:println("Date Acquired:", asset.dateAcquired);
    io:println("---------------------------------------------");
}

// ==========================================
// BOOKING MENU
// ==========================================

function bookingMenu() returns error? {

    while true {
        io:println("");
        io:println("============= BOOKING =============");
        io:println("1. Create Booking");
        io:println("2. View Bookings");
        io:println("3. Cancel Booking");
        io:println("4. Back");
        io:println("===================================");
        io:print("Select an option: ");

        string|error input = io:readln();

        if input is error {
            io:println("Unable to read input.");
            continue;
        }

        match input.trim() {
            "1" => {
                check createBooking();
            }
            "2" => {
                check viewBookings();
            }
            "3" => {
                check cancelBooking();
            }
            "4" => {
                break;
            }
            _ => {
                io:println("Invalid option.");
            }
        }
    }
}

// ==========================================
// CREATE BOOKING
// ==========================================

function createBooking() returns error? {

    io:println("");
    io:println("============= CREATE BOOKING =============");

    io:print("Enter asset tag: ");

    string|error assetInput = io:readln();

    if assetInput is error {
        io:println("Unable to read asset tag.");
        return;
    }

    string assetTag = assetInput.trim();

    if assetTag == "" {
        io:println("Asset tag cannot be empty.");
        return;
    }

    io:print("Enter booking ID: ");

    string|error bookingInput = io:readln();

    if bookingInput is error {
        io:println("Unable to read booking ID.");
        return;
    }

    string bookingId = bookingInput.trim();

    if bookingId == "" {
        io:println("Booking ID cannot be empty.");
        return;
    }

    io:print("Enter start date (YYYY-MM-DD): ");

    string|error startInput = io:readln();

    if startInput is error {
        io:println("Unable to read start date.");
        return;
    }

    string startDate = startInput.trim();

    if startDate == "" {
        io:println("Start date cannot be empty.");
        return;
    }

    io:print("Enter end date (YYYY-MM-DD): ");

    string|error endInput = io:readln();

    if endInput is error {
        io:println("Unable to read end date.");
        return;
    }

    string endDate = endInput.trim();

    if endDate == "" {
        io:println("End date cannot be empty.");
        return;
    }

    io:print("Enter booking description: ");

    string|error descriptionInput = io:readln();

    if descriptionInput is error {
        io:println("Unable to read description.");
        return;
    }

    string description = descriptionInput.trim();

    Schedule booking = {
        scheduleId: bookingId,
        scheduleType: "BOOKING",
        dueDate: startDate,
        startDate: startDate,
        endDate: endDate,
        description: description
    };

    string path = "/api/assets/" + assetTag + "/bookings";

    http:Response response = check backend->post(path, booking);

    io:println("");

    if response.statusCode == 201 {
        io:println("Booking successfully created.");
        io:println("Booking ID: ", bookingId);
        io:println("Asset Tag: ", assetTag);
        io:println("Start Date: ", startDate);
        io:println("End Date: ", endDate);
    } else {
        io:println("Unable to create booking.");
        io:println("HTTP Status: ", response.statusCode);

        string|error body = response.getTextPayload();

        if body is string {
            io:println("Message: ", body);
        }
    }
}

// ==========================================
// VIEW BOOKINGS
// ==========================================

function viewBookings() returns error? {

    io:println("");
    io:print("Enter asset tag: ");

    string|error input = io:readln();

    if input is error {
        io:println("Unable to read asset tag.");
        return;
    }

    string assetTag = input.trim();

    if assetTag == "" {
        io:println("Asset tag cannot be empty.");
        return;
    }

    string path = "/api/assets/" + assetTag + "/bookings";

    Schedule[] bookings = check backend->get(path);

    io:println("");
    io:println("============= BOOKINGS =============");

    if bookings.length() == 0 {
        io:println("No bookings found for this asset.");
        return;
    }

    foreach Schedule booking in bookings {
        io:println("");
        io:println("Booking ID:   ", booking.scheduleId);
        io:println("Type:         ", booking.scheduleType);
        io:println("Start Date:   ", booking.startDate);
        io:println("End Date:     ", booking.endDate);
        io:println("Description:  ", booking.description);
        io:println("------------------------------------");
    }

    io:println("Total bookings: ", bookings.length());
}

// ==========================================
// CANCEL BOOKING
// ==========================================

function cancelBooking() returns error? {

    io:println("");
    io:println("============= CANCEL BOOKING =============");

    io:print("Enter asset tag: ");

    string|error assetInput = io:readln();

    if assetInput is error {
        io:println("Unable to read asset tag.");
        return;
    }

    string assetTag = assetInput.trim();

    if assetTag == "" {
        io:println("Asset tag cannot be empty.");
        return;
    }

    io:print("Enter booking ID: ");

    string|error bookingInput = io:readln();

    if bookingInput is error {
        io:println("Unable to read booking ID.");
        return;
    }

    string bookingId = bookingInput.trim();

    if bookingId == "" {
        io:println("Booking ID cannot be empty.");
        return;
    }

    string path =
        "/api/assets/" + assetTag + "/bookings/" + bookingId;

    http:Response response = check backend->delete(path);

    io:println("");

    if response.statusCode == 200 {
        io:println("Booking successfully cancelled.");
        io:println("Booking ID: ", bookingId);
    } else {
        io:println("Unable to cancel booking.");
        io:println("HTTP Status: ", response.statusCode);

        string|error body = response.getTextPayload();

        if body is string {
            io:println("Message: ", body);
        }
    }
}