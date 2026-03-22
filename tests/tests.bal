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
    float THRESHOLD = 0.8;

    foreach ai:Trace trace in thread.traces {
        ai:Trace actualTrace = check hrAgentAgent.run(trace.userMessage.content.toString(), thread.id);

        string expectedOutput = (check trace.output).content.toString();
        string actualOutput = (check actualTrace.output).content.toString();

        float judgeResult = check judgeModel->generate(`You are a strict, expert evaluator grading an HR Assistant agent. Compare the ACTUAL OUTPUT to the EXPECTED OUTPUT.

Your primary focus is ensuring the agent provides **accurate, policy-grounded answers** with clear citations. Correct information alone is NOT enough — the response must reference specific policy sections and be actionable.

Rate the output on a scale of 1 to 5 based on this strict rubric:

* 1 = Incorrect or fabricated policy information, OR no policy citations at all.

* 2 = Mostly correct information, but missing key policy options or citations are vague/absent.

* 3 = Correct information with some citations, but missing important options or details present in the Expected Output.

* 4 = Accurate, well-cited response covering the key options, but missing minor details compared to the Expected Output.

* 5 = Comprehensive, accurate response with proper policy citations that matches or exceeds the Expected Output in clarity and completeness.

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
    minPassRate: 0.95,
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
