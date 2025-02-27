/**
 * @description AgentLogger provides a structured logging interface for agent activities
 * using the IsvPartners.AppAnalytics service. This class demonstrates several design
 * patterns to improve testability and maintainability.
 * 
 * Design Patterns Used:
 * 1. Dependency Injection - Analytics implementation can be swapped for testing
 * 2. Interface Segregation - IAnalytics interface defines a minimal contract
 * 3. Adapter Pattern - DefaultAnalytics adapts our interface to the external service
 * getInteractionLabel converts strings to typed enums
 * AI_INVALID_ENUM handles error cases gracefully
 * 
 */
public with sharing class AgentLogger {
  /**
   * @description Interface defining the contract for analytics functionality.
   * This allows for substitution of implementations, particularly useful for testing.
   * Following the Interface Segregation Principle, it defines only what's needed.
   */
  public interface IAnalytics {
    void logCustomInteraction(AGENT_ENUMS agentEnum);
  }
  
  /**
   * @description Default implementation that connects to the actual external analytics service.
   * This class follows the Adapter Pattern by adapting our internal interface
   * to the external IsvPartners.AppAnalytics service.
   */
  private class DefaultAnalytics implements IAnalytics {
    public void logCustomInteraction(AGENT_ENUMS agentEnum) {
      IsvPartners.AppAnalytics.logCustomInteraction(agentEnum);
    }
  }
  
  /**
   * @description Instance of the analytics implementation.
   * By default, uses the DefaultAnalytics implementation, but can be
   * replaced with a mock for testing using the setMockAnalytics method.
   * This is a key part of the Dependency Injection pattern.
   */
  @TestVisible
  private static IAnalytics analyticsInstance = new DefaultAnalytics();
  
  /**
   * @description Sets a mock analytics implementation for testing.
   * This enables unit tests to verify logging behavior without calling
   * the actual external service.
   * 
   * @param mockAnalytics The mock implementation to use during testing
   */
  @TestVisible
  private static void setMockAnalytics(IAnalytics mockAnalytics) {
    analyticsInstance = mockAnalytics;
  }
  
  /**
   * @description Enum of valid interaction types that can be logged.
   * Using enums provides type safety and validates inputs at compile time.
   * The special AI_INVALID_ENUM value handles cases where string conversion fails.
   */
  public enum AGENT_ENUMS {
    AI_INVALID_ENUM,
    HVAC_TEMP_TRIGGERED_PROMPT_FLOW
  }

  /**
   * @description Logs custom interactions for the provided component names.
   * This method converts string component names to typed enums before logging.
   * 
   * @param componentName List of component name strings to log
   * 
   * @example
   * // Log a single component
   * AgentLogger.log(new List<String>{'HVAC_TEMP_TRIGGERED_PROMPT_FLOW'});
   * 
   * // Log multiple components
   * AgentLogger.log(new List<String>{'HVAC_TEMP_TRIGGERED_PROMPT_FLOW', 'ANOTHER_ENUM_VALUE'});
   */
  public static void log(List<String> componentName) {
    // Process each component name in the list
    for (String component : componentName) {
      // Convert string to enum and log the interaction
      analyticsInstance.logCustomInteraction(
        getInteractionLabel(component)
      );
      System.debug(
        'AppAnalyticsLogger: ' +
          component +
          ' was successfully logged'
      );    
    }
  }

  /**
   * @description Converts a string component name to its corresponding enum value.
   * This factory method follows the Special Case Pattern by returning a designated
   * AI_INVALID_ENUM value when the input doesn't match any valid enum.
   * 
   * @param componentName String name to convert to enum
   * @return AGENT_ENUMS The corresponding enum value or AI_INVALID_ENUM if invalid
   */
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
      return AGENT_ENUMS.AI_INVALID_ENUM;
    }
    return enumVal;
  }
}
