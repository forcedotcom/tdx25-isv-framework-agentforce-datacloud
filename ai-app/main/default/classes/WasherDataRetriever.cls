global with sharing class WasherDataRetriever {
  @InvocableMethod
  global static List<Response> getPrompt(List<Request> requests) {
    Request input = requests[0];
    List<Response> responses = new List<Response>();
    Response output = new Response();
    responses.add(output);
    AgentLoggerGlobal.logAgentActivity('WASHER_PROMPT_FLOW');
    

    List<mvpbo2__washer__dlm> washerList = [SELECT
        mvpbo2__MaxDecibels__c,
        mvpbo2__MaxWaterTemperature__c,
        mvpbo2__SerialNumber__c,
        mvpbo2__SpinSpeed__c,
        mvpbo2__timestamp__c,
        mvpbo2__VibrationLevel__c,
        mvpbo2__WaterUsage__c
      FROM mvpbo2__washer__dlm
      WHERE mvpbo2__SerialNumber__c = :input.case_1.Appliance__r.mvpbo2__Mfg_Serial__c
      LIMIT 7
    ];

    // loop washerList and print values into a concatenated string
    for (mvpbo2__washer__dlm w : washerList) {
      output.Prompt += '\nTimestamp: ' + w.mvpbo2__timestamp__c;
      output.Prompt += '\nMax Decibels: ' + w.mvpbo2__MaxDecibels__c;
      output.Prompt += '\nMax Water Temperature: ' + w.mvpbo2__MaxWaterTemperature__c;
      output.Prompt += '\nSerial Number: ' + w.mvpbo2__SerialNumber__c;
      output.Prompt += '\nSpin Speed: ' + w.mvpbo2__SpinSpeed__c;
      output.Prompt += '\nVibration Level: ' + w.mvpbo2__VibrationLevel__c;
      output.Prompt += '\nWater Usage: ' + w.mvpbo2__WaterUsage__c;
      output.Prompt += '\n';
    }

    return responses;
  }

  // Type and API Name of all variables must match the template
  global class Request {
    @InvocableVariable(required=true)
    public Case case_1;
  }

  global class Response {
    @InvocableVariable
    public String Prompt;
  }
}
