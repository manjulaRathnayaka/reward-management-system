import ballerina/http;
public type ApiResponse record {|
    int code;
    string message;
|};

function createNotFoundError(int errorCode, string message) returns http:NotFound {
    ApiResponse response = {code: errorCode, message};
    http:NotFound errorResponse = {body: response};
    return errorResponse;
}