# MEGASharedRepo

The MEGASharedRepo is a centralized repository designed to streamline code sharing across MEGA VPN and Password Manager applications. Its purpose is to enhance code consistency, reduce redundancy, and simplify development workflows.

## This repository contains the following Swift packages:

- **MEGAAuthentication:** Provides core login, signup, and onboarding functionality.
- **MEGAAccountManagement:** Provides account management features, such as changing password, updating name, and viewing your account plan.    
- **MEGASettings:** Provides common settings related to accounts, help, and about sections shared between client apps.
- **MEGAPresentation:** Offers MVVM binding, navigation and other presentation related functionality.
- **MEGAInfrastructure:** Offers infrastructure services like keychain repository, external link opener and diagnostic related functionality.
- **MEGAUIComponent:** Provides reusable UI components for a consistent user experience.
- **MEGAConnectivity:** Manages network connectivity.
- **MEGASDKRepo:** Provides model mapping and other useful stuff related to MEGASDK.
- **MEGATest:** Provides XCTest extensions for unit and integration tests.
- **MEGASwift:** Offers general Swift extensions and reusable code.
- **MEGABuildTools:** Defines developer tooling specs, namely: `SwiftLint` and `SwiftGen` SPM plugins and `SwiftFormat`'s binary
- **MEGASharedRepoL10n:** Manages the localisation of the shared repo. The generated strings will be under the enum `SharedStrings`.
- **MEGADebugLogger:** Debug logging functionality, including a feature to share logs
- **MEGAPreference:** Helper package provides functionality to store preference.
- **MEGAAnalytics:** Provides events tracking functionality for both PWM and VPN iOS app.

## Integration

To integrate MEGASharedRepo as a git submodule:

1. In your project directory, run the following command:

    ``` bash
    git submodule add https://code.developers.mega.co.nz/mobile/ios/MEGASharedRepo.git folderPath
    ```
        
    FolderPath should be `Submodules/` in your project directory.

2. Link the libraries in your project's target.
    
    ⚠️ NOTE:
    - Make sure to add all swift packages (except tests) in the Frameworks, Libraries, and Embedded Content of the main target
    - Make sure to add all test related swift packages and other test dependency to the Frameworks, Libraries, and Embedded Content of the test target

3. Integrate MEGASDK as gitsubmodule

    ``` bash
    git submodule add https://code.developers.mega.co.nz/sdk/sdk.git folderPath
    ```
        
    FolderPath should be `Submodules/DataSource/` in your project directory.
        
    ⚠️ NOTE: Make sure to add the SDK in the correct local path (also check for caps, MEGASDK instead of MEGASdk and vice versa)
    
## Localisation

`MEGASharedRepo` manages its localisation through the `iosTransifex` submodule and the `MEGASharedRepoL1On` SPM package.

**Note**: currently the pruning (delete) operation is not supported.

## Setup

Please check the [iosTransifex repository](https://code.developers.mega.co.nz/mobile/ios/iosTransifex) and set up your `transifexConfig.json` file
**inside** the `iosTransifex` folder.

## Uploading strings

Run, from `MEGASharedRepo`'s root:

```bash
./iosTransifex/iosTransifex.py -u -r Localizable_shared_lib -l shared
```

## Downloading resources (only necessary for releases)

Run, from `MEGASharedRepo`'s root:

```bash
./iosTransifex/iosTransifex.py -m export
```

## Usage

Checkout [confluence page](https://confluence.developers.mega.co.nz/display/MOB/MEGASharedRepo) for login view integration example.

## Important links:

- **Password Manager:** [megapasswordmanager](https://code.developers.mega.co.nz/mobile/ios/megapasswordmanager)
- **VPN:** [mega-vpn-prototype](https://code.developers.mega.co.nz/mobile/ios/mega-vpn-prototype)
- **MEGASharedRepo:** [MEGASharedRepo](https://code.developers.mega.co.nz/mobile/ios/MEGASharedRepo)
- **MEGASDK:** [MEGASDK](https://code.developers.mega.co.nz/sdk/sdk)
- **MEGADesignToken:** [MEGADesignToken](https://github.com/meganz/MEGADesignToken)
