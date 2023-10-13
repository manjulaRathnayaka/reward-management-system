import ballerina/mime;
import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
@display {
    label: "bff",
    id: "bff-3b2b15db-f542-44fc-afdb-eb0413c913b3"
}
service / on new http:Listener(9090) {

    resource function get card\-details/[string userId]() returns error?|CardDetails {
        CardDetails cardDetails = {
            userId: userId,
            cardNumber: 1234567890123456,
            rewardPoints: 100,
            currentBalance: 10000,
            dueAmount: 1000,
            lastStatementBalance: 9000,
            availableCredit: 10000
        };
        return cardDetails;
    }

    resource function get rewards() returns RewardDetails[] {
        return [
            {
                "name": "Target",
                "value": 25,
                "totalPoints": 500,
                "description": "Target gift offer........"
            },
            {
                "name": "Starbucks Coffee",
                "value": 15,
                "totalPoints": 200,
                "description": "Starbucks Coffee gift offer........"
            }
        ];
    }

    resource function get generate\-qr(string text) returns http:Response|error {

        http:Client qrCodeGeneratorApi = check new (url = qrCodeGeneratorApiUrl, config = {
            auth: {
                tokenUrl: qrCodeGeneratorApiTokenUrl,
                clientId: qrCodeGeneratorApiClientId,
                clientSecret: qrCodeGeneratorApiClientSecret
            }
        });

        http:Response|http:ClientError response = qrCodeGeneratorApi->/qrcode(content = text);
        if response is http:Response  && response.statusCode == http:STATUS_OK {
                byte[] binaryPayload = check response.getBinaryPayload();
                http:Response newResponse = new;
                newResponse.setBinaryPayload(binaryPayload, mime:IMAGE_PNG);
                return newResponse;
        } else {
            return response;
        }

    }

}

configurable string qrCodeGeneratorApiUrl = ?;
configurable string qrCodeGeneratorApiTokenUrl = ?;
configurable string qrCodeGeneratorApiClientId = ?;
configurable string qrCodeGeneratorApiClientSecret = ?;



type CardDetails record {
    string userId;
    int cardNumber;
    int rewardPoints;
    int currentBalance;
    int dueAmount;
    int lastStatementBalance;
    int availableCredit;
};

type RewardDetails record {
    string name;
    int value;
    int totalPoints;
    string description;
};
