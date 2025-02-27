@isTest
private class AgentLoggerGlobalTest {
    @IsTest static void testLogAgentActivity() {
        // Create test data
        List<String> actionNames = new List<String>{'Action1', 'Action2', 'Action3'};

        // Call the AgentLoggerGlobal.logAgentActivity method
        Test.startTest();
        List<String> result = AgentLoggerGlobal.logAgentActivity(actionNames);
        Test.stopTest();

        // Assert that the result is not null
        System.assertNotEquals(null, result, 'Result should not be null');

        // Assert that the result contains the same action names
        System.assertEquals(actionNames, result, 'Result should contain the same action names');
    }

}