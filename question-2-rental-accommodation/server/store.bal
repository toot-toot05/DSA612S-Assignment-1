map<Property> properties = {};
map<UserProfile> users = {};
int nextPropertyId = 1000;

function saveProperty(AddPropertyRequest request) returns string {
    lock {
        string propertyId = "PROP-" + nextPropertyId.toString();
        nextPropertyId += 1;
        properties[propertyId] = {
            property_id: propertyId,
            property_name: request.property_name,
            location: request.location,
            property_type: request.property_type,
            price_per_night: request.price_per_night,
            status: request.status
        };
        return propertyId;
    }
}

function updateStoredProperty(UpdatePropertyRequest request) returns Property? {
    lock {
        if !properties.hasKey(request.property_id) {
            return;
        }
        Property updated = {
            property_id: request.property_id,
            property_name: request.property_name,
            location: request.location,
            property_type: request.property_type,
            price_per_night: request.price_per_night,
            status: request.status
        };
        properties[request.property_id] = updated;
        return updated;
    }
}

function registerUser(UserProfile user) {
    lock {
        users[user.user_id] = user;
    }
}

function matchingProperties(ListPropertiesRequest request) returns Property[] {
    lock {
        Property[] result = [];
        foreach Property property in properties {
            if (request.location != "" && property.location != request.location) {
                continue;
            }
            if (request.property_type != "" && property.property_type != request.property_type) {
                continue;
            }
            result.push(property);
        }
        return result;
    }
}
