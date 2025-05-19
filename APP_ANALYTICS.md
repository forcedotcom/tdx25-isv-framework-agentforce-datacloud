# Implementing App Analytics in Agentforce: Developer Guide

- [Implementing App Analytics in Agentforce: Developer Guide](#implementing-app-analytics-in-agentforce-developer-guide)
  - [Overview](#overview)
  - [Files and Structure](#files-and-structure)
    - [Core Logging Components](#core-logging-components)
    - [Test Classes](#test-classes)
    - [Example Implementation](#example-implementation)
  - [Design Patterns Used](#design-patterns-used)
  - [How to Use This Code in Your App](#how-to-use-this-code-in-your-app)
    - [Step 1: Add the Core Logging Classes](#step-1-add-the-core-logging-classes)
    - [Step 2: Define Your Events](#step-2-define-your-events)
    - [Step 3: Log Events from Apex](#step-3-log-events-from-apex)
    - [Step 4: Log Events from Flow](#step-4-log-events-from-flow)
  - [Testing Your Implementation](#testing-your-implementation)
    - [Running the Included Tests](#running-the-included-tests)
    - [Creating Your Own Tests](#creating-your-own-tests)
  - [Gotchas and Tips](#gotchas-and-tips)
  - [Example Integration: WasherDataRetriever](#example-integration-washerdataretriever)
  - [Example Questions Answered by AppAnalytics](#example-questions-answered-by-appanalytics)
  - [Additional Resources](#additional-resources)

## Overview

This repository contains a reference implementation for integrating Salesforce App Analytics with Agentforce applications. The code demonstrates best practices for logging agent activities, following well-established design patterns that promote testability and maintainability.

## Files and Structure

### Core Logging Components

- `AgentLogger.cls`: The primary class implementing analytics functionality
  - Uses enums for type-safe event tracking
  - Implements dependency injection for testability
  - Handles invalid logging requests gracefully
- `AgentLoggerGlobal.cls`: Exposes logging functionality to Flows via `@InvocableMethod`
  - Makes the logging functionality accessible from Flow Builder
- `AgentLoggerPrompt.cls`: Specialized version for logging Prompt Template activity in Flows
  - Demonstrates how to extend the pattern for specific use cases

### Test Classes

- `AgentLoggerTest.cls`: Comprehensive test class for the core AgentLogger functionality
  - Demonstrates mock objects and dependency injection in testing
  - Tests both valid and error cases
- `AgentLoggerGlobalTest.cls`: Tests for the Flow-invocable wrapper

### Example Implementation

- `WasherDataRetriever.cls`: Example class showing how to integrate logging in a real-world scenario
  - Logs activity before retrieving data from Data Cloud
  - Shows practical implementation in a Flow-callable context

## Design Patterns Used

This implementation showcases several important design patterns:

1. **Dependency Injection**: The `AgentLogger` class accepts a mock analytics implementation for testing
1. **Interface Segregation**: The `IAnalytics` interface defines only the methods needed
1. **Adapter Pattern**: `DefaultAnalytics` adapts our interface to the external `IsvPartners.AppAnalytics` service
1. **Factory Method**: `getInteractionLabel` converts strings to typed enums
1. **Special Case Pattern**: `AI_INVALID_ENUM` handles error cases gracefully

## How to Use This Code in Your App

### Step 1: Add the Core Logging Classes

Copy these files to your project:

- `AgentLogger.cls`
- `AgentLoggerGlobal.cls` (if you need Flow integration)

### Step 2: Define Your Events

Modify the `AGENT_ENUMS` enum in `AgentLogger.cls` to include your app's specific events:

```apex
public enum AGENT_ENUMS {
  AI_INVALID_ENUM,  // Keep this for error handling
  YOUR_CUSTOM_EVENT,
  ANOTHER_EVENT
  // Add your events here
}
```

### Step 3: Log Events from Apex

To log events from your Apex code:

```apex
// Log a single event
AgentLogger.log(new List<String>{'YOUR_CUSTOM_EVENT'});

// Log multiple events
AgentLogger.log(new List<String>{'YOUR_CUSTOM_EVENT', 'ANOTHER_EVENT'});
```

### Step 4: Log Events from Flow

To log events from Flow:

1. Add a new "Action" element to your flow
1. Select "Log Agent Activity" as the action type
1. For the input parameter `actionName`, enter your event name (must match an enum value in `AGENT_ENUMS`)

## Testing Your Implementation

### Running the Included Tests

The test classes demonstrate how to properly test logging implementations:

1. Use `Test.startTest()` and `Test.stopTest()` to isolate your test
1. Create a mock implementation of the IAnalytics interface
1. Use `AgentLogger.setMockAnalytics()` to inject your mock
1. Verify that the mock was called with the expected parameters

### Creating Your Own Tests

Follow this pattern to create new tests:

```apex
@isTest
static void testCustomEvent() {
  // Arrange: Set up the test environment and mock
  MockAnalytics mockAnalytics = new MockAnalytics();
  AgentLogger.setMockAnalytics(mockAnalytics);
  
  // Act: Execute the method being tested
  AgentLogger.log(new List<String>{'YOUR_CUSTOM_EVENT'});
  
  // Assert: Verify expected outcomes
  System.assertEquals(true, mockAnalytics.logCustomInteractionCalled);
  System.assertEquals('YOUR_CUSTOM_EVENT', mockAnalytics.lastInteractionLabel);
}
```

## Gotchas and Tips

Important Considerations

1. **Enum Value Matching**: Event names passed to `AgentLogger.log()` must exactly match (case-insensitive) the enum values defined in AGENT_ENUMS.
1. **Flow Invocation Limits**: Be careful about calling logging methods in loops within Flows, as you may hit governor limits.
1. **Invalid Enum Handling**: If an invalid event name is provided, the code will log it as `AI_INVALID_ENUM` rather than failing. Check your debug logs for any instances of this to catch misspelled event names.
1. **Namespace Prefixes**: If deploying in a managed package, update references to accommodate your package namespace.
1. **Data Cloud Integration**: The `WasherDataRetriever` example demonstrates integration with Data Cloud. If you're using similar functionality, ensure proper permissions are set up (like in the `PostInstall` class found in `force-app`). Reminder, `PostInstall` apex classes are not packageable alongside Data Kits.

Best Practices

1. **Be Consistent**: Create a standardized naming convention for your event enums.
1. **Log Meaningful Events**: Focus on logging significant user interactions rather than system events.
1. **Test Coverage**: Ensure you have tests for both valid cases and error handling scenarios.
1. **Documentation**: Document new enum values as you add them for team reference.

## Example Integration: WasherDataRetriever

The `WasherDataRetriever` class demonstrates how to:

1. Log an event before performing an operation
1. Use `AgentLoggerGlobal` for Flow-accessible logging
1. Handle errors gracefully while still ensuring events are logged

## Example Questions Answered by AppAnalytics

With proper instrumentation of each action, you can uncover the following types of insights from your package:

- How many of our agent actions were invoked last week by subscriber org `00D...`?
- What does adoption look like at subscriber Y? How many distinct users are using our actions?
- What is our most popular agent action across all customers?
- What is the distribution of action usage at subscriber Z? Did all users utilize agent actions evenly or is usage primarily driven by a small number of users?

## Additional Resources

- [App Analytics Documentation](https://developer.salesforce.com/docs/atlas.en-us.packagingGuide.meta/packagingGuide/app_analytics.htm)
- [Invocable Methods Documentation](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_InvocableMethod.htm)
