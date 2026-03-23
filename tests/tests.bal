import ballerina/ai;
import ballerina/test;

isolated function loadEvalsetData() returns map<[ai:ConversationThread]>|error {
    return ai:loadConversationThreads("tests/resources/evalsets/traces.evalset.json");
}

final ai:Wso2ModelProvider judgeModel = check ai:getDefaultModelProvider();

@test:Config {
    groups: ["evaluations"],
    minPassRate: 0.75,
    dataProvider: loadEvalsetData
}
function evaluateResponseClarity(ai:ConversationThread thread) returns error? {
    float totalAchievedScore = 0.0;
    float maxPossibleScore = thread.traces.count() * 5.0;
    float THRESHOLD = 0.7;

    foreach ai:Trace trace in thread.traces {
        ai:Trace actualTrace = check hrAgentAgent.run(trace.userMessage.content.toString(), thread.id);

        string expectedOutput = (check trace.output).content.toString();
        string actualOutput = (check actualTrace.output).content.toString();

        float judgeResult = check judgeModel->generate(`You are an expert evaluator grading an HR Assistant agent. Compare the ACTUAL OUTPUT to the EXPECTED OUTPUT.

The Expected Output is a **reference answer**, not the only correct answer. The Actual Output may use different wording, structure, or level of detail and still be equally correct.

First, determine whether the question is a **general HR knowledge question** (answer would be the same at any company) or a **company-specific policy question** (answer depends on ConnectWave's specific policies). For company-specific questions, the response should cite policy sections. For general knowledge questions, citations are not required.

Rate the Actual Output on a scale of 1 to 5:

* 1 = Incorrect, fabricated, or seriously misleading information.
* 2 = Partially correct but missing critical facts or key concepts that would change the employee's understanding.
* 3 = Correct on the main points but missing important secondary details that the Expected Output covers.
* 4 = Accurate and covers all key points. Minor differences in wording, structure, or supplementary details are acceptable.
* 5 = Comprehensive and accurate, covering all key points with clarity. May differ in wording or structure from the Expected Output but is equally or more helpful.

Expected Output: ${expectedOutput}

Actual Output: ${actualOutput}

Output ONLY the integer number (1, 2, 3, 4, or 5). Do not include any other text, whitespace, or reasoning.`);

        totalAchievedScore = totalAchievedScore + judgeResult;
    }

    float finalThreadScore = totalAchievedScore / maxPossibleScore;

    test:assertTrue(
            finalThreadScore >= THRESHOLD,
            msg = string `Thread failed. Cumulative score ${finalThreadScore} is below threshold ${THRESHOLD}.`
    );
}

isolated function loadEvalsetData1() returns map<[ai:ConversationThread]>|error {
    return ai:loadConversationThreads("tests/resources/evalsets/traces.evalset.json");
}

@test:Config {
    groups: ["evaluations"],
    minPassRate: 0.75,
    dataProvider: loadEvalsetData1
}
function evaluateToolTrajectory(ai:ConversationThread thread) returns error? {
    foreach ai:Trace expectedTrace in thread.traces {
        ai:FunctionCall[]? expectedToolCalls = expectedTrace.toolCalls;
        ai:Trace actualTrace = check hrAgentAgent.run(expectedTrace.userMessage.content.toString(), expectedTrace.id);
        ai:FunctionCall[]? actualToolCalls = actualTrace.toolCalls;
        if actualToolCalls == () && expectedToolCalls == () {
            continue;
        }
        if actualToolCalls == () || expectedToolCalls == () {
            test:assertEquals(actualToolCalls, expectedToolCalls);

        }
        ai:FunctionCall[] actual = check actualToolCalls.ensureType();
        ai:FunctionCall[] expected = check expectedToolCalls.ensureType();

        test:assertEquals(actual.length(), expected.length());
        foreach int index in 0 ..< actual.length() {
            test:assertEquals(actual[index].name, expected[index].name);
        }
    }
}
