/**
 * @description This class provides a Flow-invocable method for logging agent activities
 * specifically when using prompt templates. It adapts the AgentLogger functionality
 * to be easily accessible from Flow Builder through an @InvocableMethod.
 */
global with sharing class AgentLoggerPrompt {
     /**
     * @description Invocable method that can be called from Flow to log agent activities
     * related to prompt templates. This method accepts a Case record and action name,
     * logs the activity using AgentLoggerGlobal, and returns an empty prompt string
     * that can be used in Flow.
     * 
     * @param requests List of Request objects containing Case record and action name to log
     * @return List<Response> Response object with an empty Prompt string
     * @throws ListException if more than one request is provided
     * 
     * @example
     * In Flow Builder:
     * 1. Add an Action element
     * 2. Select "Flow - Log Agent Activity" as the action type
     * 3. Pass the current Case record to case_1
     * 4. Provide the action name (must match an enum in AgentLogger.AGENT_ENUMS)
     */
    @InvocableMethod(category='PropertyManager' label='Flow - Log Agent Activity' description='Log agent activity for a Prompt Template when using a Flow retriever.')
    global static List<Response> logAgentActivityPrompt(List<Request> requests) {

        List<String> actionName = new List<String>();
        List<Response> responses = new List<Response>();
        Response output = new Response();
        responses.add(output);

        System.debug(requests);
        if (requests.size() != 1) {
            throw new ListException('Only one request is allowed.');
        }
        
        output.Prompt = '';
        AgentLoggerGlobal.logAgentActivity(actionName);
        return responses;
    }

     /**
     * @description Request class for the logAgentActivityPrompt invocable method.
     * Contains parameters required for the logging operation.
     */
    global class Request {
        /**
         * @description The Case record associated with this logging activity
         */
        @InvocableVariable(required=true)
        global Case case_1;
        /**
         * @description The name of the action to log (should match a value in AgentLogger.AGENT_ENUMS)
         */
        @InvocableVariable(required=true)
        global String action_name;
    }

    /**
     * @description Response class for the logAgentActivityPrompt invocable method.
     * Contains the output prompt string (empty in this implementation).
     */
    global class Response {
        /**
         * @description The prompt string to be returned to the Flow.
         * Currently initialized as empty, but could be extended to
         * provide confirmation or additional context if needed.
         */
        @InvocableVariable
        global String Prompt;
    }
}