import ballerina/ai;
import ballerinax/ai.openai;
import ballerinax/ai.pinecone;

final pinecone:VectorStore pineconeVectorstore = check new (string `${pineconeServiceUrl}`, string `${pineconeApiKey}`);
final openai:EmbeddingProvider openaiEmbeddingprovider = check new (string `${openAiApiKey}`, "text-embedding-ada-002");
final ai:VectorKnowledgeBase aiVectorknowledgebase = new (pineconeVectorstore, openaiEmbeddingprovider);
final openai:ModelProvider openaiModelprovider = check new (string `${openAiApiKey}`, "gpt-4o", retryConfig = {
    count: 3,
    interval: 2,
    backOffFactor: 2,
    maxWaitInterval: 3
});
