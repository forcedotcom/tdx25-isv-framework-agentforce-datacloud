global with sharing class WasherDataRetriever {
  @InvocableMethod
  global static List<Response> getPrompt(List<Request> requests) {
    Request input = requests[0];
    List<Response> responses = new List<Response>();
    Response output = new Response();
    responses.add(output);
    List<String> actionName = new List<String>{'WASHER_PROMPT_FLOW'};
    AgentLoggerGlobal.logAgentActivity(actionName);

    ConnectApi.CdpQueryInput query = new ConnectApi.CdpQueryInput();
      query.sql = 'SELECT ' +
              'mvpbo2__MaxDecibels__c,' +
              'mvpbo2__MaxWaterTemperature__c,' +
              'mvpbo2__SerialNumber__c,' +
              'mvpbo2__SpinSpeed__c,' +
              'mvpbo2__timestamp__c,' +
              'mvpbo2__VibrationLevel__c,' +
              'mvpbo2__WaterUsage__c ' +
            'FROM mvpbo2__washer__dlm ' +
            'LIMIT 7';

      try {
      ConnectApi.CdpQueryOutputV2 response = ConnectApi.CdpQuery.queryAnsiSqlV2(query);    
          

          Map<String, ConnectApi.CdpQueryMetadataItem> responseMetadata = response.metadata;
          // loop washerList and print values into a concatenated string
    for (ConnectApi.CdpQueryV2Row row : response.data) {
        // Access the row data using field names as keys
          output.Prompt += '\nTimestamp: ' + responseMetadata.get('mvpbo2__timestamp__c').placeInOrder;
          output.Prompt += '\nMax Decibels: ' + responseMetadata.get('mvpbo2__MaxDecibels__c').placeInOrder;
          output.Prompt += '\nMax Water Temperature: ' + responseMetadata.get('mvpbo2__MaxWaterTemperature__c').placeInOrder;
          output.Prompt += '\nSerial Number: ' + responseMetadata.get('mvpbo2__SerialNumber__c').placeInOrder;
          output.Prompt += '\nSpin Speed: ' + responseMetadata.get('mvpbo2__SpinSpeed__c').placeInOrder;
          output.Prompt += '\nVibration Level: ' + responseMetadata.get('mvpbo2__VibrationLevel__c').placeInOrder;
          output.Prompt += '\nWater Usage: ' + responseMetadata.get('mvpbo2__WaterUsage__c').placeInOrder;
          output.Prompt += '\n';
    }

      } catch (Exception e) {
          System.debug(e);
      }

    // FIX
    // List<mvpbo2__washer__dlm> washerList = [SELECT
    //     mvpbo2__MaxDecibels__c,
    //     mvpbo2__MaxWaterTemperature__c,
    //     mvpbo2__SerialNumber__c,
    //     mvpbo2__SpinSpeed__c,
    //     mvpbo2__timestamp__c,
    //     mvpbo2__VibrationLevel__c,
    //     mvpbo2__WaterUsage__c
    //   FROM mvpbo2__washer__dlm
    //   WHERE mvpbo2__SerialNumber__c = :input.case_1.Appliance__r.mvpbo2__Mfg_Serial__c
    //   LIMIT 7
    // ];

    

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
