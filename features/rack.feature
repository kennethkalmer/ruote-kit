Example: ruote-kit is built on rack
ruote-kit configures its own rack "stack"
ruote-kit can use custom middleware

Scenario: Default rack setup
Given ruote-kit has booted
Then ruote-kit should have a rack
And ruote-kit should have the "CommonLogger" middleware loaded
And ruote-kit should have the "Lint" middleware loaded

Scenario: Default rack handler
Given ruote-kit has booted
Then ruote-kit should use the "Thin" rack handler

@delayedboot
Scenario: Failed rack handler
Given ruote-kit is configured to use the "NonExistant" rack handler
And ruote-kit has booted
Then ruote-kit should use the "Thin" rack handler

@delayedboot
Scenario: Configurable rack handler
Given ruote-kit is configured to use the "Mongrel" rack handler
And ruote-kit has booted
Then ruote-kit should use the "Mongrel" rack handler

@delayedboot
Scenario: Configurable authentication
Given ruote-kit is configured to use the "yaml auth" middleware
And ruote-kit has booted
Then ruote-kit should have the "YAMLAuth" middleware loaded
