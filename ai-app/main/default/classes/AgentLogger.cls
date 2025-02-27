public with sharing class AgentLogger {
  public enum AGENT_ENUMS {
    HVAC_TEMP_TRIGGERED_PROMPT_FLOW
  }

  public static void log(List<String> componentName) {
    // loop list can call custom interaction for each component
    for (String component : componentName) {
      IsvPartners.AppAnalytics.logCustomInteraction(
        getInteractionLabel(component)
      );
      System.debug(
        'AppAnalyticsLogger: ' +
          componentName +
          ' was successfully logged'
      );    
    }
  }

  private static AGENT_ENUMS getInteractionLabel(
    String componentName
  ) {
    string name = componentName.toUpperCase();
    AGENT_ENUMS enumVal;
    try {
      enumVal = AGENT_ENUMS.valueOf(name);
    } catch (Exception e) {
      System.debug(
        'Invalid interaction label provided ' + componentName 
      );
      return enumVal;
    }
    return enumVal;
  }
}
