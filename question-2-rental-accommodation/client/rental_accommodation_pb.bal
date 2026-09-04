import ballerina/grpc;
import ballerina/protobuf;

public const string RENTAL_ACCOMMODATION_DESC = "0A1A72656E74616C5F6163636F6D6D6F646174696F6E2E70726F746F121372656E74616C6163636F6D6D6F646174696F6E22BA010A1241646450726F70657274795265717565737412230A0D70726F70657274795F6E616D65180120012809520C70726F70657274794E616D65121A0A086C6F636174696F6E18022001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180320012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180420012801520D70726963655065724E6967687412160A06737461747573180520012809520673746174757322500A1341646450726F7065727479526573706F6E7365121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412180A076D65737361676518022001280952076D657373616765226D0A0B5573657250726F66696C6512170A07757365725F69641801200128095206757365724964121B0A0966756C6C5F6E616D65180220012809520866756C6C4E616D6512140A05656D61696C1803200128095205656D61696C12120A04726F6C651804200128095204726F6C6522540A134372656174655573657273526573706F6E736512230A0D75736572735F63726561746564180120012805520C75736572734372656174656412180A076D65737361676518022001280952076D65737361676522DE010A1555706461746550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412230A0D70726F70657274795F6E616D65180220012809520C70726F70657274794E616D65121A0A086C6F636174696F6E18032001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180420012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180520012801520D70726963655065724E6967687412160A0673746174757318062001280952067374617475732287010A1655706461746550726F7065727479526573706F6E736512180A077570646174656418012001280852077570646174656412180A076D65737361676518022001280952076D65737361676512390A0870726F706572747918032001280B321D2E72656E74616C6163636F6D6D6F646174696F6E2E50726F7065727479520870726F706572747922580A154C69737450726F7065727469657352657175657374121A0A086C6F636174696F6E18012001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180220012809520C70726F70657274795479706522D1010A0850726F7065727479121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412230A0D70726F70657274795F6E616D65180220012809520C70726F70657274794E616D65121A0A086C6F636174696F6E18032001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180420012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180520012801520D70726963655065724E6967687412160A06737461747573180620012809520673746174757332A5030A1A52656E74616C4163636F6D6D6F646174696F6E5365727669636512600A0B41646450726F706572747912272E72656E74616C6163636F6D6D6F646174696F6E2E41646450726F7065727479526571756573741A282E72656E74616C6163636F6D6D6F646174696F6E2E41646450726F7065727479526573706F6E7365125B0A0B437265617465557365727312202E72656E74616C6163636F6D6D6F646174696F6E2E5573657250726F66696C651A282E72656E74616C6163636F6D6D6F646174696F6E2E4372656174655573657273526573706F6E7365280112690A0E55706461746550726F7065727479122A2E72656E74616C6163636F6D6D6F646174696F6E2E55706461746550726F7065727479526571756573741A2B2E72656E74616C6163636F6D6D6F646174696F6E2E55706461746550726F7065727479526573706F6E7365125D0A0E4C69737450726F70657274696573122A2E72656E74616C6163636F6D6D6F646174696F6E2E4C69737450726F70657274696573526571756573741A1D2E72656E74616C6163636F6D6D6F646174696F6E2E50726F70657274793001620670726F746F33";

public isolated client class RentalAccommodationServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, RENTAL_ACCOMMODATION_DESC);
    }

    isolated remote function AddProperty(AddPropertyRequest|ContextAddPropertyRequest req) returns AddPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyRequest message;
        if req is ContextAddPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rentalaccommodation.RentalAccommodationService/AddProperty", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddPropertyResponse>result;
    }

    isolated remote function AddPropertyContext(AddPropertyRequest|ContextAddPropertyRequest req) returns ContextAddPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyRequest message;
        if req is ContextAddPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rentalaccommodation.RentalAccommodationService/AddProperty", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function UpdateProperty(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns UpdatePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rentalaccommodation.RentalAccommodationService/UpdateProperty", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UpdatePropertyResponse>result;
    }

    isolated remote function UpdatePropertyContext(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns ContextUpdatePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rentalaccommodation.RentalAccommodationService/UpdateProperty", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UpdatePropertyResponse>result, headers: respHeaders};
    }

    isolated remote function CreateUsers() returns CreateUsersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("rentalaccommodation.RentalAccommodationService/CreateUsers");
        return new CreateUsersStreamingClient(sClient);
    }

    isolated remote function ListProperties(ListPropertiesRequest|ContextListPropertiesRequest req) returns stream<Property, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListPropertiesRequest message;
        if req is ContextListPropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("rentalaccommodation.RentalAccommodationService/ListProperties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return new stream<Property, grpc:Error?>(outputStream);
    }

    isolated remote function ListPropertiesContext(ListPropertiesRequest|ContextListPropertiesRequest req) returns ContextPropertyStream|grpc:Error {
        map<string|string[]> headers = {};
        ListPropertiesRequest message;
        if req is ContextListPropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("rentalaccommodation.RentalAccommodationService/ListProperties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return {content: new stream<Property, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class CreateUsersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUserProfile(UserProfile message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUserProfile(ContextUserProfile message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveCreateUsersResponse() returns CreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <CreateUsersResponse>payload;
        }
    }

    isolated remote function receiveContextCreateUsersResponse() returns ContextCreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <CreateUsersResponse>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class PropertyStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Property value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Property value;|} nextRecord = {value: <Property>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public type ContextUserProfileStream record {|
    stream<UserProfile, error?> content;
    map<string|string[]> headers;
|};

public type ContextPropertyStream record {|
    stream<Property, error?> content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyResponse record {|
    UpdatePropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextListPropertiesRequest record {|
    ListPropertiesRequest content;
    map<string|string[]> headers;
|};

public type ContextUserProfile record {|
    UserProfile content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyRequest record {|
    UpdatePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextAddPropertyResponse record {|
    AddPropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextAddPropertyRequest record {|
    AddPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersResponse record {|
    CreateUsersResponse content;
    map<string|string[]> headers;
|};

public type ContextProperty record {|
    Property content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type UpdatePropertyResponse record {|
    boolean updated = false;
    string message = "";
    Property property = {};
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type ListPropertiesRequest record {|
    string location = "";
    string property_type = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type UserProfile record {|
    string user_id = "";
    string full_name = "";
    string email = "";
    string role = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type UpdatePropertyRequest record {|
    string property_id = "";
    string property_name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type AddPropertyResponse record {|
    string property_id = "";
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type AddPropertyRequest record {|
    string property_name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type CreateUsersResponse record {|
    int users_created = 0;
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type Property record {|
    string property_id = "";
    string property_name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
|};
