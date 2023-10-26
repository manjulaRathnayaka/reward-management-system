import ballerina/mime;
import ballerina/log;
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
            rewardPoints: 3760,
            currentBalance: 1250.39,
            dueAmount: 1000,
            lastStatementBalance: 1692.88,
            availableCredit: 14500
        };
        return cardDetails;
    }

    resource function get rewards() returns RewardOffer[] | error{
        log:printInfo("get all rewards aviailable");
        http:Client loyaltyAPI = check new (url = loyaltyMangementApiUrl, config = {
            auth: {
                tokenUrl: tokenUrl,
                clientId: clientId,
                clientSecret: clientSecret
            }
        });

        RewardOffer[] rewardsOffers = check loyaltyAPI->/rewards();

        return rewardsOffers;
   }

    resource function get rewards/[string rewardId]() returns RewardOffer| error {
        log:printInfo("get reward by id", rewardId = rewardId);
        http:Client loyaltyAPI = check new (url = loyaltyMangementApiUrl, config = {
            auth: {
                tokenUrl: tokenUrl,
                clientId: clientId,
                clientSecret: clientSecret
            }
        });

        RewardOffer rewardOffer = check loyaltyAPI->/rewards/[rewardId]();
        return rewardOffer;
    }

    resource function get generate\-qr(string text) returns http:Response|error {
        log:printInfo("generate qr code for text", text = text);
        http:Client qrCodeGeneratorApi = check new (url = qrCodeGeneratorApiUrl, config = {
            auth: {
                tokenUrl: tokenUrl,
                clientId: clientId,
                clientSecret: clientSecret
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

configurable string loyaltyMangementApiUrl = ?;
configurable string qrCodeGeneratorApiUrl = ?;
configurable string tokenUrl = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;



type CardDetails record {
    string userId;
    int cardNumber;
    int rewardPoints;
    float currentBalance;
    float dueAmount;
    float lastStatementBalance;
    float availableCredit;
};

type RewardOffer record {
    string id;
    string name;
    float value;
    int totalPoints;
    string description;
    string logoUrl;
};

