import ballerina/ai;
import ballerina/http;

listener ai:Listener hrAgentListener = new (listenOn = check http:getDefaultListener());

service /hrAgent on hrAgentListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string stringResult = check hrAgentAgent.run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
