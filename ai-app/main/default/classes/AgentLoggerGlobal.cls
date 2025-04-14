global with sharing class AgentLoggerGlobal {
    /**
     * Logs agent activity for a given action.
     *
     * @param actionNames A list of action names representing the activities to be logged.
     * @return A list of action names that were passed in.
     * @throws Exception If an error occurs during the logging process.
     * 
     * @InvocableMethod
     *   - category: 'PropertyManager'
     *   - label: 'Log Agent Activity'
     *   - description: 'Log agent activity for a given action.'
     */
    @InvocableMethod(category='PropertyManager' label='Log Agent Activity' description='Log agent activity for a given action.')
    global static List<String> logAgentActivity(List<String> actionNames) {
        try {
            AgentLogger.log(actionNames);
        } catch (Exception e) {
            System.debug('Error logging agent activity: ' + e.getMessage());
        }
        return actionNames;
    }
}