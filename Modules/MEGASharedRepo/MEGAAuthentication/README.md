# MEGAAuthentication

    MEGAAuthentication is a Swift package that provides the core functionality for login, signup, and onboarding in MEGA applications. 
    It encapsulates common logic and components for user authentication and onboarding, simplifying development and ensuring consistency
    across different applications.

## Features:

    - Centralized login, signup, and onboarding experience.
    - Secure and robust authentication mechanisms.
    - Easy integration with MEGA applications.
    - Localization support (currently injected from consumer apps).

## Dependencies:

    - CasePaths
    - MEGADesignToken
    - MEGAUIComponent
    - MEGAConnectivity
    - MEGASDK
    - MEGASDKRepo
    - MEGAPresentation
    - MEGAInfrastructure
    - MEGASwift
    - MEGATest

## Usage:

1. Import the package:

    ```import MEGAAuthentication```

2.Inject dependencies:
    ```
    MEGAAuthentication.DependencyInjection.sharedSdk = .sharedSDK
    MEGAAuthentication.DependencyInjection.keychainServiceName = "MEGAPasswordManager"
    MEGAAuthentication.DependencyInjection.appGroup = "group.nz.mega.MEGAPasswordManager"
    ```

3. Use the provided components and functionalities:
    - LoginView: Provides a pre-built login UI with email, password, and login button.
    - SignupView: Provides a pre-built signup UI.
