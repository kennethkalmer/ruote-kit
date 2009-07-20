Example: Booting ruote-kit
Configuring the engine

Scenario: ruote-kit should have a logger
Given ruote-kit has booted
Then ruote-kit should have a logger

Scenario: ruote-kit should have an engine
Given ruote-kit has booted
Then ruote-kit should have a engine
And the engine should be using "file system" persistence
And the engine should have a "wild card" "fs" participant

@delayedboot
Scenario: ruote-kit should support "transient" mode
Given ruote-kit is configured to use "transient" mode
And ruote-kit has booted
Then the engine should be using "no" persistence
And the engine should have a "wild card" "hash" participant

@delayedboot
Scenario: ruote-kit should support "active record" mode
Given ruote-kit is configured to use "active record" mode
And ruote-kit has booted
Then the engine should be using "active record" persistence
And the engine should have a "wild card" "ar" participant
