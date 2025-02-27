/**
 * @description Test class for AgentLogger that demonstrates effective unit testing
 * strategies for classes that use dependency injection patterns.
 * 
 * Testing Patterns Demonstrated:
 * 1. Mock Objects - Uses a mock implementation of the IAnalytics interface
 * 2. Dependency Injection - Replaces the default analytics implementation with a test double
 * 3. Behavior Verification - Verifies the mock was called with expected parameters
 * 4. Arrange-Act-Assert Pattern - Clearly separates test setup, execution, and verification
 * 5. Edge Case Testing - Tests both valid and invalid input scenarios
 * 
 * @see AgentLogger
 * @author Your Team
 * @date Current Date
 */
@isTest
private class AgentLoggerTest {
  /**
   * @description Mock implementation of the AgentLogger.IAnalytics interface.
   * This test double captures information about how it was called so we can
   * verify the behavior of the class under test without depending on the
   * actual external service.
   * 
   * It demonstrates the Mock Object pattern by implementing the same interface
   * as the real dependency but with test-specific behavior.
   */
  private class MockAnalytics implements AgentLogger.IAnalytics {
    public Boolean logCustomInteractionCalled = false;
    public String lastInteractionLabel;
    
    /**
     * @description Implementation of the interface method that records calls
     * instead of calling the actual external service.
     * 
     * @param label The enum value that would normally be passed to the service
     */
    public void logCustomInteraction(AgentLogger.AGENT_ENUMS label) {
      logCustomInteractionCalled = true;
      lastInteractionLabel = label.name();
    }
  }
  
  /**
   * @description Tests that AgentLogger.log correctly processes a valid component name.
   * Demonstrates the Arrange-Act-Assert pattern and behavior verification.
   * 
   * This test verifies that:
   * 1. The AgentLogger calls the analytics service
   * 2. It correctly passes the proper enum value
   * 
   * @see AgentLogger.log
   */
  @isTest
  static void testLogCustomInteraction() {
    // Arrange: Set up the test environment and mock dependencies
    MockAnalytics mockAnalytics = new MockAnalytics();
    AgentLogger.setMockAnalytics(mockAnalytics);
    
    // Act: Execute the method being tested
    AgentLogger.log(new List<String>{ 'HVAC_TEMP_TRIGGERED_PROMPT_FLOW' });
    
    // Assert: Verify the expected outcomes
    System.assertEquals(true, mockAnalytics.logCustomInteractionCalled, 
      'logCustomInteraction should be called');
    System.assertEquals('HVAC_TEMP_TRIGGERED_PROMPT_FLOW', mockAnalytics.lastInteractionLabel, 
      'Incorrect label was logged');
  }
  
  /**
   * @description Tests that AgentLogger.log correctly handles invalid component names.
   * Demonstrates edge case testing for error handling.
   * 
   * This test verifies that:
   * 1. The AgentLogger gracefully handles invalid input
   * 2. It uses the special AI_INVALID_ENUM value for unrecognized components
   * 3. The analytics service is still called even with invalid input
   * 
   * @see AgentLogger.getInteractionLabel
   */
  @isTest
  static void testLogCustomInteractionInvalidLabel() {
    // Arrange: Set up the test environment and mock dependencies
    MockAnalytics mockAnalytics = new MockAnalytics();
    AgentLogger.setMockAnalytics(mockAnalytics);
    
    // Act: Execute the method with invalid input
    AgentLogger.log(new List<String>{ 'INVALID_COMPONENT_NAME' });
    
    // Assert: Verify the error handling behavior
    System.assertEquals(true, mockAnalytics.logCustomInteractionCalled, 
      'logCustomInteraction should be called even with invalid label');
    System.assertEquals('AI_INVALID_ENUM', mockAnalytics.lastInteractionLabel, 
      'Invalid label should result in AI_INVALID_ENUM value');
  }
}
