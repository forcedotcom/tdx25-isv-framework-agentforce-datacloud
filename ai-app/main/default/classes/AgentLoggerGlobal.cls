// Global class to wrap around public classes
global with sharing class AgentLoggerGlobal {
    @InvocableMethod(category='PropertyManager'label='Log Agent Activity' description='Log agent activity for a given action.')
    global static List<String> logAgentActivity(List<String> actionName) {
        AgentLogger.log(actionName);
        return actionName;
    }
}