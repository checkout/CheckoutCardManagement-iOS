# Table of Contents
- [What is the CheckoutCardManagement-iOS SDK?](#What-is-the-CheckoutCardManagement-iOS-SDK)
- [Environments](#Environments)
  - [Migrating from Stub to Sandbox and Production](#Migrating_from_Stub_to_Sandbox_and_Production)
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

Our CheckoutCardManagement-iOS SDK is the mobile gateway to our wider [card issuing solution](https://www.checkout.com/docs/card-issuing). It enables your mobile application to securely access important card information and functionality, in a fast and safe way.

***
# Environments

The iOS SDK supports 3 environments: Stub, Sandbox, and Production.

These environments are accessed through the 2 libraries available to you when you import the SDK with Swift Package Manager (SPM):
- **CheckoutCardManagerStub**, which powers the Stub environment. Stub allows you to begin testing the APIs in your app, without having to wait for the legal and contractual arrangements required by the other environments, or for backend integration to be completed. The Stub environment is completely isolated; you can provide empty strings instead of tokens in your API calls as no network calls leave the device, and we provide mock data in the responses.
- **CheckoutCardManager**, which powers the Sandbox and Production environments. Use of these environments requires onboarding with our operations team. During onboarding, you'll receive client credentials, which you will then need to handle on your backend for authentication. You will be expected to manage [Strong Custom Authentication (SCA) requirements](https://www.checkout.com/docs/payments/regulation-support/sca-compliance-guide) as part of accessing the SDK's functionality.

## Migrating from Stub to Sandbox and Production

When you're ready to migrate from the Stub environment, simply update the import statement from `import CheckoutCardManagerStub` to `import CheckoutCardManager`. No additional changes are required, and the public interfaces remain the same.

In the Live version of your app, you'll be expected to provide valid tokens in your requests, which our backend services will serve securely.

***
# Sample Application

Refer to [our sample application](https://github.com/checkout/CheckoutCardManagement-iOS/tree/main/Sample%20Application) for a guidance of integration.

***
# Features

### Easy to integrate
Your app can consume the SDK directly through SPM; there is no additional setup required, meaning you can get up and running quickly.

For detailed steps on how to add a package, see Apple's [Add a package dependency](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#Add-a-package-dependency) documentation. Use our SDKs URL `https://github.com/checkout/CheckoutCardManagement-iOS` and ensure you use the latest release.

### Decoupled integration
You can use the [Stub environment](#Environments) to begin work on UI development separately, without having to wait for network and other integrations to be completed.

### Developer friendly
We value the Swift community and are big fans of following community-defined best practices. As such, our APIs are designed with the [Swift API design guidelines](https://www.swift.org/documentation/api-design-guidelines/) in mind, so usage will feel familiar.

Whilst we are light on UI, we've provided you with flexible UI customization options so that you can adhere to Apple's [Human Interface guidelines](https://developer.apple.com/design/human-interface-guidelines/guidelines/overview/).

### Feature-rich
Our SDK aims to integrate with all of our backend services for SDK-relevant features.

Whether you're retrieving a list of cards for a cardholder, accessing sensitive card information, or adding a card to the Apple wallet, our SDK makes it easy for you to provide this functionality to your users.

### Compliant
Using the SDK keeps you compliant with the [Payment Card Industry Data Security Standards (PCI DSS)](https://www.checkout.com/docs/payments/regulation-support/pci-compliance).

If you have any specific questions about PCI compliance, reach out to your operations contact.

***
# Requirements
The SDK is distributed as a native iOS package. If you have a hybrid project, review your hybrid platform's documentation for guidance on how to consume native third-party SDKs.

You should have **SCA** enabled for your users. Whilst we take care of in-depth compliance, you are required to perform SCA on your users as requested and documented.

Each authentication session can be used to simultaneously generate multiple tokens for different systems. For example, for sign in, or to get an SDK session token or an internal authentication token. However, only one SDK token can be generated from each SCA flow requested.

***
# Integration

### Import SDK
Use SPM to import the SDK into your app:

1. In **Xcode**, select _File > Swift Packages > Add Package Dependency_.
2. When prompted, enter `enter https://github.com/checkout/CheckoutCardManagement-iOS`.

See Apple's [Add a package dependency](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#Add-a-package-dependency) documentation for more information.

At this stage, you can choose to add the `CheckoutCardManagement` or `CheckoutCardManagementStub` library to your application target. If you're unsure about which library you should use, see our [Environments](#Environments) section.

### Prepare card manager
To start consuming SDK functionality, instantiate the main object, which enables access to the functionality:
```Swift
// The statement should match the library imported in the previous step
import CheckoutCardManagement

class YourObject {
   // Customizable UI properties for the secure components delivered by the SDK
   let cardManagerDesignSystem = CardManagementDesignSystem(font: .systemFont(ofSize: 22),
                                                            textColor: .blue)
   // The core object through which the SDK's functionality is accessed 
   let cardManager = CheckoutCardManager(designSystem: cardManagerDesignSystem,
                                         environment: .sandbox)
}
```

### Login user
In order to provide your users with the SDK functionality, you must authenticate them for the session.

In a Live environment, **you are responsible for ensuring you authenticate a user** for the session. This means your application should retrieve a session token from your authentication backend.

In a Stub environment, you can provide any `String`.
```Swift
let token = "{Token_retrieved_from_your_backend}"
cardManager.logIn(with: token)
```

### Get a list of cards
Once you’ve authenticated the cardholder, and your application, you can return a list of non-sensitive card data using `getCards` for that cardholder.

This returns the following card details:
- **last 4 digits of the long card number**, also known as the Primary Account Number (PAN)
- card's **expiry date**
- **cardholder's** name
- card's **state** (inactive, active, suspended, or revoked)
- a **unique ID** for each card returned

```Swift
cardManager.getCards { result in
    switch result {
    case .success(let cards):
        // You'll receive a list of cards that you can integrate within your UI
        // The card info includes the last 4 digits (PAN), expiry date, cardholder name, card state, and id
    case .failure(let error):
        // If something goes wrong, you'll receive an error with more details
    }
}
```

### Update card state
The API is attached to the card object, so you must first obtain it from the SDK.

Once you have the card object, we would also suggest using our `.possibleStateChanges` card API for an improved user experience. You can then request the new state from the card object.
```Swift
// This will return a list of possible states that the card can be transitioned to
let possibleNewStates = card.possibleStateChanges

// We can activate the card, if the state was returned by possibleStateChanges
if possibleNewStates.contains(.active) {
    card.activate(completionHandler: cardStateChangeCompletion)
}

// We can suspend the card, if the state was returned by possibleStateChanges
if possibleNewStates.contains(.suspended) {
    // You can choose to pass an optional reason for why you're suspending the card
    let reason: CardSuspendReason? = .lost
    card.suspend(reason: reason, completionHandler: cardStateChangeCompletion)
}

// We can revoke the card, if the state was returned by possibleStateChanges
if possibleNewStates.contains(.revoked) {
    // This is a destructive and irreversible action - once revoked, the card cannot be reactivated
    // We recommended that you request UI confirmation that your user intended to perform this action
    // You can choose to pass an optional reason for why you're revoking the card     
    let reason: CardRevokeReason? = .lost
    card.revoke(reason: reason, completionHandler: cardStateChangeCompletion)
}
```

Regardless of the new state requested, the same completion handler can be used:
```Swift
func cardStateChangeCompletion(_ result: CheckoutCardManager.OperationResult) {
    switch result {
    case .success:
        // Card state has been updated successfully, and will be reflected by both the backend and the SDK
    case .failure(let error):
        // If something goes wrong, you'll receive an error with more details
    }
}
```

Note: card states. There are 4 different card states, which apply to both virtual and physical cards. They are:
| Status      | Description |
| ----------- | ----------- |
| Inactive    | The card is awaiting activation and is unusable until then. By default, physical cards are set to `inactive` on creation. Cards cannot transition to `inactive` from any other status.        |
| Active      | The card can process transactions as normal. By default, virtual cards are set to `active` on creation.   |
| Suspended   | Card has been manually suspended by the cardholder; transactions are temporarily blocked. The card can be reactivated to allow for normal use.  |
| Revoked     | Transactions are permanently blocked. The card cannot be reactivated from this status. |

### Retrieve Secure Data
<sub> The following example covers PIN, but similar APIs are available for PAN, CVV, and PAN + CVV. The general flow remains the same.</sub>

These calls are subject to a unique SCA flow prior to every individual call. Only on completion of a specific authentication can a single-use token be requested and provided to the SDK, in order to continue executing the request.

In a Stub environment, you can provide any `String`.

```Swift
let singleUseToken = "{Single_use_token_retrieved_from_your_backend_after_SCA}"

// Request sensitive data via the card object
card.getPin(singleUseToken: singleUseToken) { result in
    switch result {
    case .success(let pinView):
        // If successful, you'll receive a UI component that you can display to the user
    case .failure(let error):
        // If something goes wrong, you'll receive an error with more details
    }
}
```
The UI component protects the value and safely delivers it to the user as the sole recipient. The UI component design can be adjusted as appropriate when [creating the card manager](#Prepare-card-manager) and providing the `CardManagementDesignSystem`.

### Push Provisioning
**Push Provisioning** is the operation of adding a physical or virtual card to a digital wallet. On iOS, this means adding a card to an Apple Wallet.

Enabling this operation is highly complex as it requires interaction between multiple entities including you, Checkout.com, Apple, and the card scheme (in our case, Mastercard).  As such, push provisioning is subject to onboarding and can only be tested in your Production environment. For more details, speak to your operations contact.

A typical call may look as follows:
```Swift
card.provision(cardholderID: "{id_of_cardholder_performing_operation}",
               configuration: ProvisioningConfiguration(/* */),
               provisioningToken: "{specific_token_generated_for_operation}")
```

There are some behaviors to be aware of when you attempt a push provisioning operation:
- if you're using the `CheckoutCardManagement` library, calling it without completing proper onboarding will result in an intentional crash.
- if you're using the `CheckoutCardManagementStub` library, the operation will behave as expected, but no interaction with Apple Wallet, Checkout.com, or the card scheme will occur. Depending on which Checkout.com environment you're using with Stub, you will receive one of two results:
  - in the sandbox Checkout.com environment, you'll receive a `pushProvisioningFailure` error, as push provisioning is only valid in production
  - in the production Checkout.com environment, you'll receive an `OperationResult` success message

***
# Contact
For Checkout.com issuing clients, please email issuing_operations@checkout.com for any questions.
