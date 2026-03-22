import ballerina/ai;
import ballerinax/ai.openai;
import ballerinax/ai.pinecone;
import ballerinax/googleapis.calendar;

final pinecone:VectorStore pineconeVectorstore = check new (string `${pineconeServiceUrl}`, string `${pineconeApiKey}`);
final openai:EmbeddingProvider openaiEmbeddingprovider = check new (string `${openAiApiKey}`, "text-embedding-ada-002");
final ai:VectorKnowledgeBase aiVectorknowledgebase = new (pineconeVectorstore, openaiEmbeddingprovider);
final openai:ModelProvider openaiModelprovider = check new (string `${openAiApiKey}`, "gpt-4o-mini", retryConfig = {
    count: 3,
    interval: 2,
    backOffFactor: 2,
    maxWaitInterval: 3
});

final calendar:Client calendarClient = check new ({
    auth: {
        refreshUrl: googleRefreshUrl,
        refreshToken: googleRefreshToken,
        clientId: googleClientId,
        clientSecret: googleClientSecret
    }
});
