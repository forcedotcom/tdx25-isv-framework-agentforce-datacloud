global with sharing class AgentLoggerPrompt {

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

    global class Request {
        @InvocableVariable(required=true)
        global Case case_1;
        @InvocableVariable(required=true)
        global String action_name;
    }

    global class Response {
        @InvocableVariable
        global String Prompt;
    }
}