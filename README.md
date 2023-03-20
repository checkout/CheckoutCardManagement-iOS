# Table of Contents
- [What is the CheckoutCardManagement-iOS SDK?](#What-is-the-CheckoutCardManagement-iOS-SDK)
- [Environments](#Environments)
- [Features](#Features)
- [Requirements](#Requirements)
- [Integration](#Integration)
    - [Import SDK](#Import-SDK)
    - [Prepare Card Manager](#Prepare-Card-Manager)
    - [Login user](#Login-user)
    - [Get a list of cards](#Get-a-list-of-cards)
    - [Update card state](#Update-card-state)
    - [Retrieve Secure Data](#Retrieve-secure-data)
    - [Push Provisioning](#Push-provisioning)
- [Contact](#Contact)
***


# What is the CheckoutCardManagement-iOS SDK?

Our iOS SDK is the mobile gateway to our wider Issuing solution. It enables your mobile application to securely access important card information and functionality, in a fast and safe way.

***
# Environments

CheckoutCardManagement-iOS SDK supports 3 environments: Stub, Sandbox & Production. When importing the SDK via SPM, we provide access to 2 separate libraries:
- **CheckoutCardManager**. This library powers Sandbox & Production environments, and requires onboarding with our operations team. During onboarding, you will need to receive client credentials, which you will then need to handle on your backend for authentication. You will be expected to manage SCA capabilities as part of accessing our SDK's functionality.
- **CheckoutCardManagerStub**. This library powers Stub and is the quickest way to try the APIs in your app. Your mobile team can integrate this way whilst waiting for legal & contractual arrangements to take place, or for your backend colleagues to get integration ready on their side.
    - in this version you can provide empty strings instead of tokens as no network call leaves the device and we provide mock data.
> **_IMPORTANT FACT:_**  Changing from CheckoutCardManagerStub to CheckoutCardManager is as simple as updating the `import CheckoutCardManagerStub` to `import CheckoutCardManager`. On Live versions you will be expected to start providing valid tokens that our backend services will be able to serve securely. 

***
# Features

### Easy to integrate
Being consumable via SPM straight into your application means there is no fidly setup to handle. If you need help, see [Apple's Add A Package Dependency](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#Add-a-package-dependency) guides to add the package. Just use our SDKs URL https://github.com/checkout/CheckoutCardManagement-iOS and ensure you use the latest release.
> **_NOTE_:** Did you see we provide a Stub version? You can get the UI prepared whilst you prepare your network and other integrations 👍

### Developer friendly
We value the Swift community and we are big fans of best practices in the community. Our APIs aim to follow [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/). 
Whilst we are light on UI, we also aimed to enable you plenty of UI customisability so our components will keep it easy for your team to follow [Apple's Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/guidelines/overview/).

### Feature rich
Our SDK aims to integrate with all of our backend services for SDK relevant features. So whether it’s retrieving a list of cards for a cardholder, accessing sensitive card information, or adding a card to the Apple wallet, our SDK makes it easy to provide this functionality to your users.

### Compliant
There are a number of compliance benefits that come from using the SDK, such as adhering to PCI compliance. Please raise any specific compliance questions with your operations contact.

***
# Requirements
The SDK is distributed as a native iOS package. If you have a hybrid project, you might need to see how your hybrid platform can consume native 3rd party SDKs.

You should have **SCA** enabled for your users. Whilst we take care of in depth compliance, we need you to perform SCA on your users as requested and documented. Each authentication can be done to generate multiple tokens for different systems at the same time (ie: on sign in, get SDK session token & your internal authentication token from 1 sign in). But only 1 SDK token can be generated on each SCA flow requested!

***
# Integration

### Import SDK
We love Swift Package Manager, so we would recommend this approach to import the SDK into your application.
As [Apple's Doc](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#Add-a-package-dependency) advise:
> From Xcode select File > Swift Packages > Add Package Dependency and enter https://github.com/checkout/CheckoutCardManagement-iOS

Depending on your readiness stage, then select between `CheckoutCardManagement` and `CheckoutCardManagementStub` to add to your application target. If unsure which one you are ready for, see [Environments](#Environments).

### Prepare card manager
To start consuming SDK functionality you will need to instantiate the main object enabling access to the functionality.
```Swift
// Should match the library imported at previous step, between CheckoutCardManagement and CheckoutCardManagementStub
import CheckoutCardManagement

class YourObject {
   // Customisasable UI properties for the secure components delivered
   let cardManagerDesignSystem = CardManagementDesignSystem(font: .systemFont(ofSize: 22),
                                                            textColor: .blue)
   // Core object enabling functionality 
   let cardManager = CheckoutCardManager(designSystem: cardManagerDesignSystem,
                                         environment: .sandbox)
}
```

### Login user
In order to provide your users with the SDK functionality, you need to authenticate them for the session. 
In a live environment, this will mean your application retrieves a session token from your authentication backend and **you are responsible for ensuring you authenticate an user** for the session.
If using Stub, you can provide any String.
```Swift
let token = "{Token_retrieved_from_your_backend}"
cardManager.logIn(with: token)
```

### Get a list of cards
Once you’ve authenticated your application and the cardholder, you can return a list of non-sensitive card data using `getCards`. This returns the **last 4 digits of the long card number** for our cards (also known as the Primary Account Number, or PAN), the **expiry date** of the card, the name of the **cardholder** associated with that card, the **state** of that card, and the unique ID for each card returned.

```Swift
cardManager.getCards { result in
    switch result {
    case .success(let cards):
        // received a list of cards that you can integrate inside your UI
        // Card info contains: last 4 pan, expiry date, cardholder name, card state & id
    case .failure(let error):
        // received an error. Error should help document what went wrong
    }
}
```

### Update card state
API is attached to the card object, so you will need to first obtain the card object from the SDK. Once you have the card object, we would also suggest using our `.possibleStateChanges` card API for an improved UX. You can then request the new state from the card object
```Swift
// 1. We can retrieve possible new states for the card we want to update state of
let possibleNewStates = card.possibleStateChanges

// If valid, we can activate card
if possibleNewStates.contains(.active) {
    card.activate(completionHandler: cardStateChangeCompletion)
}

// If valid, we can suspend card
if possibleNewStates.contains(.suspended) {
    let reason: CardSuspendReason? = .lost
    card.activate(reason: reason, completionHandler: cardStateChangeCompletion)
}

// If valid we can revoke card
if possibleNewStates.contains(.revoked) {
    // This is a destructive and irreversible action, ensure your user is certain
    //     Once revoked, the card can no longer be activated!
    let reason: CardRevokeReason? = .lost
    card.activate(reason: reason, completionHandler: cardStateChangeCompletion)
}
```

Regardless of the new state requested, the same completion handler can be used:
```Swift
func cardStateChangeCompletion(_ result: CheckoutCardManager.OperationResult) {
    switch result {
    case .success:
        // The card state has been updated as requested, both on backend and SDK
    case .failure(let error):
        // received an error. Error should help document what went wrong
    }
}
```

Note: card states. There are 4 different card states, which apply to both virtual and physical cards. They are:
| State      | Meaning |
| ----------- | ----------- |
| Active      | Card is active and can be used as normal.       |
| Suspended   | Card has been manually suspended by the cardholder, and can be reactivated to be used normally. Reactivation would return it to the Active state.        |
| Inactive   | Physical cards are created as inactive by default. Virtual cards are created as active by default. No matter the card's status, you cannot deactivate a card.        |
| Revoked   | Deleted. At this point, you cannot re-active the card. It is forever deleted.        |

### Retrieve Secure Data
<sub>Example covers PIN, but the same flow and similar APIs are valid for PAN, CVV, PAN + CVV</sub>

These calls are subject to a unique Strong Customer Authentication flow prior to every individual call. Only on completion of such a specific authentication, a single use token may be requested to continue executing the request and must be provided to the SDK.
If using Stub, you can provide any String.

```swift
let singleUseToken = "{Single_use_token_retrieved_from_your_backend_after_SCA}"

// Request sensitive data via the card object
card.getPin(singleUseToken: singleUseToken) { result in
    switch result {
    case .success(let pinView):
        // received an UI component we can now display to the user
    case .failure(let error):
        // received an error. It should document what went wrong
    }
}
```
The UI Component protects the value and safely delivers it only to the user. The UI Component design can be adjusted as appropriate when [creating the card manager](#Prepare-card-manager) and providing the CardManagementDesignSystem.

### Push Provisioning
Push Provisioning is the operation of adding a physical or virtual card to the digital wallet. On iOS this is the Apple Wallet. The operation is complex and requires interaction from many different entities, including Apple & Card Scheme (in our case, Mastercard). Push Provisioning is subject to onboarding and will only be testable in Production. For more details on setting up Push Provisioning, please speak to your operations contact.
Code level, the call will look like:
```Swift
card.provision(cardholderID: "{id_of_cardholder_performing_operation}",
               configuration: ProvisioningConfiguration(/* */),
               provisioningToken: "{specific_token_generated_for_operation}")
```
There are some behaviours to keep in mind when attempting the operation:
- In the **CheckoutCardManagement library**, calling it without the onboarding will result in a crash. This is intentional to ensure an application cannot be deployed without correct onboarding being performed.
- In the **CheckoutCardManagementStub library**, the standard expected behaviour will occur, without interacting with Apple Wallet, Checkout, or Card Scheme. This means that:
    - using Sandbox - An error will be delivered, of type `pushProvisioningFailure`. Push Provisioning is only valid in a Production environment
    - using Production - A success OperationResult will be received.

***
# Contact
For CKO issuing clients, please email issuing_operations@checkout.com for any questions.
