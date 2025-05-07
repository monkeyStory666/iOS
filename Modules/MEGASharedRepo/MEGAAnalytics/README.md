# MEGAAnalytics
    
    MEGAAnalytics is a Swift package which provides events tracking functionality for both PWM and VPN iOS app. 
    It is a wrapper on top of MEGAAnalyticsiOS KMM library, and provides all of the setup needed for easily sending events to our MEGAStats analytics.

## Features:

    - Centralized analytics tracking

## Dependencies:

    - MEGASDK
    - MEGASDKRepo
    - MEGAAnalyticsiOS

## Usage:

1. Import the package:

    ```import MEGAAnalytics```

2.Inject dependencies:
    ```
    MEGAAnalytics.DependencyInjection.sharedSdk = .sharedSDK
    ```
3. Inject MEGAAnalyticsTracker instance into the view model which should be responsible for sending the analytics event. If the project doesn't support swift-dependencies, like PWM currently, you should use it like this: 
    ```
    private let analyticsTracker: any MEGAAnalyticsTrackerProtocol
    ```
    If the project supports swift-dependencies, like VPN project currently, you should use it like this after registering it: 
    ```
    @Dependency(\.analyticsTracker)
    var analyticsTracker
    ```

4. Trigger event tracking 
    ```
    analyticsTracker.trackAnalyticsEvent(with: SomeEventWeShouldTrack())
    ```
