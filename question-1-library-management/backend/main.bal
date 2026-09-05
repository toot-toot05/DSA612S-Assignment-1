import ballerina/http;
import ballerina/time;

// ================================================================
// IN-MEMORY INSTITUTION REGISTRY
// ================================================================

table<Institution> key(name) institutionRegistry = table [
    {
        name: "Namibia University of Science and Technology",
        sites: [
            "Main Campus - Innovation Lab"
        ]
    }
];


// ================================================================
// HTTP SERVICE
// ================================================================

service /api on new http:Listener(8080) {

    // ============================================================
    // ASSET MANAGEMENT
    // ============================================================

    // GET all assets
    resource function get assets() returns Asset[] {
        return assets.toArray();
    }

    // GET a single asset by assetTag
    resource function get assets/[string assetTag]()
            returns Asset|http:NotFound {

        if assets.hasKey(assetTag) {
            return assets.get(assetTag);
        }

        return <http:NotFound>{
            body: {
                message: "Asset not found",
                assetTag: assetTag
            }
        };
    }

    // CREATE a new asset
    resource function post assets(Asset asset)
            returns Asset|http:Conflict {

        if assets.hasKey(asset.assetTag) {
            return <http:Conflict>{
                body: {
                    message: "Asset with this assetTag already exists",
                    assetTag: asset.assetTag
                }
            };
        }

        assets.add(asset);
        return asset;
    }

    // UPDATE an existing asset
    resource function put assets/[string assetTag](Asset updatedAsset)
            returns Asset|http:NotFound|http:BadRequest {

        if assetTag != updatedAsset.assetTag {
            return <http:BadRequest>{
                body: {
                    message: "Path assetTag does not match payload assetTag"
                }
            };
        }

        if assets.hasKey(assetTag) {
            assets.put(updatedAsset);
            return updatedAsset;
        }

        return <http:NotFound>{
            body: {
                message: "Asset not found",
                assetTag: assetTag
            }
        };
    }

    // DELETE an asset
    resource function delete assets/[string assetTag]()
            returns http:NoContent|http:NotFound {

        if assets.hasKey(assetTag) {
            _ = assets.remove(assetTag);
            return <http:NoContent>{};
        }

        return <http:NotFound>{
            body: {
                message: "Asset not found",
                assetTag: assetTag
            }
        };
    }


    // ============================================================
    // INSTITUTION AND SITE FILTERING
    // ============================================================

    // GET assets by institution
    resource function get assets/institution/[string institution]()
            returns Asset[] {

        Asset[] result = [];

        foreach Asset asset in assets {
            if asset.institution == institution {
                result.push(asset);
            }
        }

        return result;
    }

    // GET assets by institution AND site
    resource function get assets/institution/[string institution]/site/[string site]()
            returns Asset[] {

        Asset[] result = [];

        foreach Asset asset in assets {
            if asset.institution == institution && asset.site == site {
                result.push(asset);
            }
        }

        return result;
    }


    // ============================================================
// MAINTENANCE / OVERDUE
// ============================================================

// GET assets with overdue schedules
resource function get assets/maintenance/overdue()
        returns Asset[] {

    time:Civil currentTime = time:utcToCivil(time:utcNow());

    string month = currentTime.month < 10
        ? string `0${currentTime.month}`
        : string `${currentTime.month}`;

    string day = currentTime.day < 10
        ? string `0${currentTime.day}`
        : string `${currentTime.day}`;

    string today = string `${currentTime.year}-${month}-${day}`;

    Asset[] result = [];

    foreach Asset asset in assets {

        boolean overdue = false;

        foreach Schedule schedule in asset.schedules {

            if schedule.dueDate < today {
                overdue = true;
                break;
            }
        }

        if overdue {
            result.push(asset);
        }
    }

    return result;
}


    // ============================================================
    // COMPONENT MANAGEMENT
    // ============================================================

    // ADD a component to an asset
    resource function post assets/[string assetTag]/components(
            Component component)
            returns Asset|http:NotFound|http:Conflict {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        foreach Component existingComponent in asset.components {

            if existingComponent.compId == component.compId {
                return <http:Conflict>{
                    body: {
                        message: "Component with this compId already exists",
                        compId: component.compId,
                        assetTag: assetTag
                    }
                };
            }
        }

        asset.components.push(component);
        assets.put(asset);

        return asset;
    }

    // REMOVE a component from an asset
    resource function delete assets/[string assetTag]/components/[string compId]()
            returns Asset|http:NotFound {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        int componentIndex = -1;

        foreach int index in 0 ..< asset.components.length() {

            if asset.components[index].compId == compId {
                componentIndex = index;
                break;
            }
        }

        if componentIndex == -1 {
            return <http:NotFound>{
                body: {
                    message: "Component not found",
                    compId: compId,
                    assetTag: assetTag
                }
            };
        }

        _ = asset.components.remove(componentIndex);
        assets.put(asset);

        return asset;
    }


    // ============================================================
    // SCHEDULE MANAGEMENT
    // ============================================================

    // GET all schedules for an asset
    resource function get assets/[string assetTag]/schedules()
            returns Schedule[]|http:NotFound {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        return asset.schedules;
    }

    // ADD a schedule to an asset
    resource function post assets/[string assetTag]/schedules(
            Schedule schedule)
            returns Asset|http:NotFound|http:Conflict {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        foreach Schedule existingSchedule in asset.schedules {

            if existingSchedule.scheduleId == schedule.scheduleId {
                return <http:Conflict>{
                    body: {
                        message: "Schedule with this scheduleId already exists",
                        scheduleId: schedule.scheduleId,
                        assetTag: assetTag
                    }
                };
            }
        }

        asset.schedules.push(schedule);
        assets.put(asset);

        return asset;
    }

    // REMOVE a schedule from an asset
    resource function delete assets/[string assetTag]/schedules/[string scheduleId]()
            returns Asset|http:NotFound {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        int scheduleIndex = -1;

        foreach int index in 0 ..< asset.schedules.length() {

            if asset.schedules[index].scheduleId == scheduleId {
                scheduleIndex = index;
                break;
            }
        }

        if scheduleIndex == -1 {
            return <http:NotFound>{
                body: {
                    message: "Schedule not found",
                    scheduleId: scheduleId,
                    assetTag: assetTag
                }
            };
        }

        _ = asset.schedules.remove(scheduleIndex);
        assets.put(asset);

        return asset;
    }

    // ============================================================
// LOAN MANAGEMENT
// ============================================================

// LOAN an asset
resource function post assets/[string assetTag]/loan()
        returns Asset|http:NotFound|http:Conflict {

    if !assets.hasKey(assetTag) {
        return <http:NotFound>{
            body: {
                message: "Asset not found",
                assetTag: assetTag
            }
        };
    }

    Asset asset = assets.get(assetTag);

    // An asset can only be loaned when it is available.
    if asset.status != "AVAILABLE" {
        return <http:Conflict>{
            body: {
                message: "Asset cannot be loaned because it is not available",
                assetTag: assetTag,
                status: asset.status
            }
        };
    }

    asset.status = "LOANED_OUT";
    assets.put(asset);

    return asset;
}


// RETURN a loaned asset
resource function post assets/[string assetTag]/'return()
        returns Asset|http:NotFound|http:Conflict {

    if !assets.hasKey(assetTag) {
        return <http:NotFound>{
            body: {
                message: "Asset not found",
                assetTag: assetTag
            }
        };
    }

    Asset asset = assets.get(assetTag);

    // Only a loaned asset can be returned.
    if asset.status != "LOANED_OUT" {
        return <http:Conflict>{
            body: {
                message: "Asset cannot be returned because it is not currently loaned out",
                assetTag: assetTag,
                status: asset.status
            }
        };
    }

    asset.status = "AVAILABLE";
    assets.put(asset);

    return asset;
}

    // ============================================================
// BOOKING MANAGEMENT
// ============================================================

// CREATE a booking for an asset
resource function post assets/[string assetTag]/bookings(
        Schedule booking)
        returns Asset|http:NotFound|http:Conflict|http:BadRequest {

    if !assets.hasKey(assetTag) {
        return <http:NotFound>{
            body: {
                message: "Asset not found",
                assetTag: assetTag
            }
        };
    }

    // A booking must be explicitly marked as BOOKING.
    if booking.scheduleType != "BOOKING" {
        return <http:BadRequest>{
            body: {
                message: "Booking schedule must have scheduleType BOOKING",
                scheduleId: booking.scheduleId
            }
        };
    }

    // Booking dates are required.
    if booking.startDate == "" || booking.endDate == "" {
        return <http:BadRequest>{
            body: {
                message: "Booking requires startDate and endDate",
                scheduleId: booking.scheduleId
            }
        };
    }

    // Validate that the start date is not after the end date.
    if booking.startDate > booking.endDate {
        return <http:BadRequest>{
            body: {
                message: "Booking startDate cannot be after endDate",
                scheduleId: booking.scheduleId
            }
        };
    }

    Asset asset = assets.get(assetTag);

    // Assets that are unavailable cannot be booked.
    if asset.status == "LOANED_OUT" ||
            asset.status == "OCCUPIED" ||
            asset.status == "UNDER_MAINTENANCE" ||
            asset.status == "DISPOSED" {

        return <http:Conflict>{
            body: {
                message: "Asset cannot be booked in its current status",
                assetTag: assetTag,
                status: asset.status
            }
        };
    }

    // Check for duplicate schedule IDs.
    foreach Schedule existingSchedule in asset.schedules {

        if existingSchedule.scheduleId == booking.scheduleId {
            return <http:Conflict>{
                body: {
                    message: "Schedule with this scheduleId already exists",
                    scheduleId: booking.scheduleId,
                    assetTag: assetTag
                }
            };
        }
    }

    // Check for overlapping bookings.
    foreach Schedule existingSchedule in asset.schedules {

        if existingSchedule.scheduleType == "BOOKING" {

            boolean overlaps =
                booking.startDate <= existingSchedule.endDate &&
                booking.endDate >= existingSchedule.startDate;

            if overlaps {
                return <http:Conflict>{
                    body: {
                        message: "Booking conflicts with an existing booking",
                        scheduleId: booking.scheduleId,
                        conflictingScheduleId: existingSchedule.scheduleId,
                        assetTag: assetTag
                    }
                };
            }
        }
    }

    asset.schedules.push(booking);
    assets.put(asset);

    return asset;
}


// GET all bookings for an asset
resource function get assets/[string assetTag]/bookings()
        returns Schedule[]|http:NotFound {

    if !assets.hasKey(assetTag) {
        return <http:NotFound>{
            body: {
                message: "Asset not found",
                assetTag: assetTag
            }
        };
    }

    Asset asset = assets.get(assetTag);
    Schedule[] bookings = [];

    foreach Schedule schedule in asset.schedules {

        if schedule.scheduleType == "BOOKING" {
            bookings.push(schedule);
        }
    }

    return bookings;
}


// CANCEL a booking
resource function delete assets/[string assetTag]/bookings/[string scheduleId]()
        returns Asset|http:NotFound|http:Conflict {

    if !assets.hasKey(assetTag) {
        return <http:NotFound>{
            body: {
                message: "Asset not found",
                assetTag: assetTag
            }
        };
    }

    Asset asset = assets.get(assetTag);

    int bookingIndex = -1;

    foreach int index in 0 ..< asset.schedules.length() {

        Schedule schedule = asset.schedules[index];

        if schedule.scheduleId == scheduleId &&
                schedule.scheduleType == "BOOKING" {

            bookingIndex = index;
            break;
        }
    }

    if bookingIndex == -1 {
        return <http:NotFound>{
            body: {
                message: "Booking not found",
                scheduleId: scheduleId,
                assetTag: assetTag
            }
        };
    }

    _ = asset.schedules.remove(bookingIndex);
    assets.put(asset);

    return asset;
}

    // ============================================================
    // WORK ORDER MANAGEMENT
    // ============================================================

    // GET all work orders for an asset
    resource function get assets/[string assetTag]/workorders()
            returns WorkOrder[]|http:NotFound {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        return asset.workOrders;
    }

    // ADD a work order to an asset
    resource function post assets/[string assetTag]/workorders(
            WorkOrder workOrder)
            returns Asset|http:NotFound|http:Conflict {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        foreach WorkOrder existingOrder in asset.workOrders {

            if existingOrder.orderId == workOrder.orderId {
                return <http:Conflict>{
                    body: {
                        message: "Work order with this orderId already exists",
                        orderId: workOrder.orderId,
                        assetTag: assetTag
                    }
                };
            }
        }

        asset.workOrders.push(workOrder);
        assets.put(asset);

        return asset;
    }

    // UPDATE a work order
    resource function put assets/[string assetTag]/workorders/[string orderId](
            WorkOrder updatedWorkOrder)
            returns Asset|http:NotFound|http:BadRequest {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        if orderId != updatedWorkOrder.orderId {
            return <http:BadRequest>{
                body: {
                    message: "Path orderId does not match payload orderId"
                }
            };
        }

        Asset asset = assets.get(assetTag);

        int orderIndex = -1;

        foreach int index in 0 ..< asset.workOrders.length() {

            if asset.workOrders[index].orderId == orderId {
                orderIndex = index;
                break;
            }
        }

        if orderIndex == -1 {
            return <http:NotFound>{
                body: {
                    message: "Work order not found",
                    orderId: orderId,
                    assetTag: assetTag
                }
            };
        }

        asset.workOrders[orderIndex] = updatedWorkOrder;
        assets.put(asset);

        return asset;
    }

    // DELETE a work order
    resource function delete assets/[string assetTag]/workorders/[string orderId]()
            returns Asset|http:NotFound {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        int orderIndex = -1;

        foreach int index in 0 ..< asset.workOrders.length() {

            if asset.workOrders[index].orderId == orderId {
                orderIndex = index;
                break;
            }
        }

        if orderIndex == -1 {
            return <http:NotFound>{
                body: {
                    message: "Work order not found",
                    orderId: orderId,
                    assetTag: assetTag
                }
            };
        }

        _ = asset.workOrders.remove(orderIndex);
        assets.put(asset);

        return asset;
    }


    // ============================================================
    // SUB-TASK MANAGEMENT
    // ============================================================

    // GET all tasks for a work order
    resource function get assets/[string assetTag]/workorders/[string orderId]/tasks()
            returns Task[]|http:NotFound {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        foreach WorkOrder workOrder in asset.workOrders {

            if workOrder.orderId == orderId {
                return workOrder.tasks;
            }
        }

        return <http:NotFound>{
            body: {
                message: "Work order not found",
                orderId: orderId,
                assetTag: assetTag
            }
        };
    }

    // ADD a task to a work order
    resource function post assets/[string assetTag]/workorders/[string orderId]/tasks(
            Task task)
            returns Asset|http:NotFound|http:Conflict {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        int orderIndex = -1;

        foreach int index in 0 ..< asset.workOrders.length() {

            if asset.workOrders[index].orderId == orderId {
                orderIndex = index;
                break;
            }
        }

        if orderIndex == -1 {
            return <http:NotFound>{
                body: {
                    message: "Work order not found",
                    orderId: orderId,
                    assetTag: assetTag
                }
            };
        }

        foreach Task existingTask in asset.workOrders[orderIndex].tasks {

            if existingTask.taskId == task.taskId {
                return <http:Conflict>{
                    body: {
                        message: "Task with this taskId already exists",
                        taskId: task.taskId,
                        orderId: orderId,
                        assetTag: assetTag
                    }
                };
            }
        }

        asset.workOrders[orderIndex].tasks.push(task);
        assets.put(asset);

        return asset;
    }

    // REMOVE a task from a work order
    resource function delete assets/[string assetTag]/workorders/[string orderId]/tasks/[string taskId]()
            returns Asset|http:NotFound {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        int orderIndex = -1;

        foreach int index in 0 ..< asset.workOrders.length() {

            if asset.workOrders[index].orderId == orderId {
                orderIndex = index;
                break;
            }
        }

        if orderIndex == -1 {
            return <http:NotFound>{
                body: {
                    message: "Work order not found",
                    orderId: orderId,
                    assetTag: assetTag
                }
            };
        }

        int taskIndex = -1;

        foreach int index in 0 ..< asset.workOrders[orderIndex].tasks.length() {

            if asset.workOrders[orderIndex].tasks[index].taskId == taskId {
                taskIndex = index;
                break;
            }
        }

        if taskIndex == -1 {
            return <http:NotFound>{
                body: {
                    message: "Task not found",
                    taskId: taskId,
                    orderId: orderId,
                    assetTag: assetTag
                }
            };
        }

        _ = asset.workOrders[orderIndex].tasks.remove(taskIndex);
        assets.put(asset);

        return asset;
    }


    // ============================================================
    // INSTITUTION MANAGEMENT
    // ============================================================

    // GET all institutions
    resource function get institutions() returns Institution[] {
        return institutionRegistry.toArray();
    }

    // GET a single institution
    resource function get institutions/[string institutionName]()
            returns Institution|http:NotFound {

        if institutionRegistry.hasKey(institutionName) {
            return institutionRegistry.get(institutionName);
        }

        return <http:NotFound>{
            body: {
                message: "Institution not found",
                name: institutionName
            }
        };
    }

    // ADD a new institution
    resource function post institutions(Institution institution)
            returns Institution|http:Conflict {

        if institutionRegistry.hasKey(institution.name) {
            return <http:Conflict>{
                body: {
                    message: "Institution already exists",
                    name: institution.name
                }
            };
        }

        institutionRegistry.add(institution);

        return institution;
    }

    // DELETE an institution
    resource function delete institutions/[string institutionName]()
            returns http:NoContent|http:NotFound|http:Conflict {

        if !institutionRegistry.hasKey(institutionName) {
            return <http:NotFound>{
                body: {
                    message: "Institution not found",
                    name: institutionName
                }
            };
        }

        // An institution cannot be deleted while assets
        // are still assigned to it.
        foreach Asset asset in assets {

            if asset.institution == institutionName {
                return <http:Conflict>{
                    body: {
                        message: "Institution cannot be deleted because assets are still assigned to it",
                        name: institutionName,
                        assetTag: asset.assetTag
                    }
                };
            }
        }

        _ = institutionRegistry.remove(institutionName);

        return <http:NoContent>{};
    }


    // ============================================================
    // SITE MANAGEMENT
    // ============================================================

    // GET all sites belonging to an institution
    //
    // Example:
    // GET /api/institutions/University%20of%20Namibia/sites
    //
    resource function get institutions/[string institutionName]/sites()
            returns string[]|http:NotFound {

        if !institutionRegistry.hasKey(institutionName) {
            return <http:NotFound>{
                body: {
                    message: "Institution not found",
                    name: institutionName
                }
            };
        }

        Institution institution = institutionRegistry.get(institutionName);

        return institution.sites;
    }


    // GET/check one specific site
    //
    // Example:
    // GET /api/institutions/University%20of%20Namibia/sites/Northern%20Campus
    //
    resource function get institutions/[string institutionName]/sites/[string site]()
            returns string|http:NotFound {

        if !institutionRegistry.hasKey(institutionName) {
            return <http:NotFound>{
                body: {
                    message: "Institution not found",
                    name: institutionName
                }
            };
        }

        Institution institution = institutionRegistry.get(institutionName);

        foreach string existingSite in institution.sites {

            if existingSite == site {
                return existingSite;
            }
        }

        return <http:NotFound>{
            body: {
                message: "Site not found",
                site: site,
                institution: institutionName
            }
        };
    }


    // ADD a site to an institution
    //
    // The site is part of the URL path.
    //
    // Example:
    // POST /api/institutions/University%20of%20Namibia/sites/Northern%20Campus
    //
    resource function post institutions/[string institutionName]/sites/[string site]()
            returns Institution|http:NotFound|http:Conflict {

        if !institutionRegistry.hasKey(institutionName) {
            return <http:NotFound>{
                body: {
                    message: "Institution not found",
                    name: institutionName
                }
            };
        }

        Institution institution = institutionRegistry.get(institutionName);

        // Check for duplicate site
        foreach string existingSite in institution.sites {

            if existingSite == site {
                return <http:Conflict>{
                    body: {
                        message: "Site already exists",
                        site: site,
                        institution: institutionName
                    }
                };
            }
        }

        // Add site
        institution.sites.push(site);

        // Replace institution in table
        institutionRegistry.put(institution);

        return institution;
    }


    // DELETE a site from an institution
    //
    // Example:
    // DELETE /api/institutions/University%20of%20Namibia/sites/Northern%20Campus
    //
    resource function delete institutions/[string institutionName]/sites/[string site]()
            returns Institution|http:NotFound|http:Conflict {

        if !institutionRegistry.hasKey(institutionName) {
            return <http:NotFound>{
                body: {
                    message: "Institution not found",
                    name: institutionName
                }
            };
        }

        Institution institution = institutionRegistry.get(institutionName);

        int siteIndex = -1;

        // Find the site
        foreach int index in 0 ..< institution.sites.length() {

            if institution.sites[index] == site {
                siteIndex = index;
                break;
            }
        }

        // Site does not exist
        if siteIndex == -1 {
            return <http:NotFound>{
                body: {
                    message: "Site not found",
                    site: site,
                    institution: institutionName
                }
            };
        }

        // Do not allow the site to be deleted while
        // an asset is still assigned to it.
        foreach Asset asset in assets {

            if asset.institution == institutionName &&
                    asset.site == site {

                return <http:Conflict>{
                    body: {
                        message: "Site cannot be deleted because assets are still assigned to it",
                        site: site,
                        institution: institutionName,
                        assetTag: asset.assetTag
                    }
                };
            }
        }

        // Remove site
        _ = institution.sites.remove(siteIndex);

        // Update institution in registry
        institutionRegistry.put(institution);

        return institution;
    }
}