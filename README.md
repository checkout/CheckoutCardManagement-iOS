# What is the CheckoutCardManagement-iOS SDK?

Our SDK is a first step at integrating with our full Issuing Product solution. It works in the same way as our real production SDK will do, but is currently powered by an internal ‘Stub’ framework, which returns random data. This means there’s no backend integration required for the ‘Stub’ version of CheckoutCardManagement-iOS. 

The public interface remains the same no matter whether it’s fake/mocked data, as in the case of ‘Stub’, or real data. This means you have a small switch from **Stub → Sandbox → Production**. 

Using the SDK, you can get a sense of what your card management flow can look like in your app. Our SDK is very light on UI elements, simply returning secure UI views for sensitive information, and we’ve left most of the UI interpretation to you so that you can power the experience you want!

You don’t need to be signed up to our issuing solution to use our ‘Stub’ version - it’s open source and free.

**It’s important to note that all the data the Stub provides is fake, randomly generated data. No real data is involved.**


# Integrating our CheckoutCardManagement-iOS SDK

Accessing CheckoutCardManagement-iOS through Swift Package Manager

Using Swift Package Manager, import our SDK (https://github.com/checkout/CheckoutCardManagement-iOS) with the latest release number + `-stub`.

### Prepare card manager

To start consuming SDK functionality you will need to instantiate the main object enabling access to the functionality.
```Swift
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

### Register a session with your backend and authenticate the card manager

In order to securely access our Issuing APIs.
```Swift
let token = "{Token_retrieved_from_your_backend}"
cardManager.logIn(with: token)
```

<sub>Note that you don’t need a real token for Stub, we’re just mocking what you’d have to do if this was the real thing.</sub>

### Retrieve a list of cards associated with the account your backend authorised
<sub>Also applicable to other non-PCI requests</sub>

As shown in the below snippet, once you’ve authenticated your application and the cardholder, you can return a list of non-sensitive card data using `getCards`. This returns the **last 4 digits of the long card number** for our cards (also known as the Personal Account Number, or PAN), the **expiry date** of the card, the name of the **cardholder** associated with that card, the **state** of that card, and the unique ID for each card returned.

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
Note: card states. There are 4 different card states, which apply to both virtual and physical cards. They are:
| State      | Meaning |
| ----------- | ----------- |
| Active      | Card is active and can be used as normal.       |
| Suspended   | Card has been manually suspended by the cardholder, and can be reactivated to be used normally. Reactivation would return it to the Active state.        |
| Inactive   | Physical cards are created as inactive by default. Virtual cards are created as active by default. No matter the card's status, you cannot deactivate a card.        |
| Revoked   | Deleted. At this point, you cannot re-active the card. It is forever deleted.        |



### Retrieve a PIN for one of the cards
<sub>The flow is similar for other sensitive information, like the long card number (PAN), or the security code (CVV)</sub>

```swift
// Authenticate your user for this request and on success, request a sensitive data specific token from your backend
// Not relevant when using Stub
let singleUseToken = retrieveSensitiveDataToken(generatedFor: reauthenticatedUser)

// Using an index from the list of cards (for example from user UI selection), request the PIN for that card
cards[selectedIndex].getPin(singleUseToken: singleUseToken) { result in
    switch result {
    case .success(let pinView):
        // received an UI component we can now display to the user
    case .failure(let error):
        // received an error. It should document what went wrong
    }
}
```


### Moving to Sandbox and Production

Changing environments

When CheckoutCardManagement-iOS is using the ‘Stub’ framework, it does not look at the environment config as all the data being returned is ‘mock’ data.
When consuming our SDK with non Stub, the environemnt config will allow you to select different environments as required.

Note that testing in Sandbox and Production requires you to be set-up operationally with our Issuing service. For CKO issuing clients, please email issuing_operations@checkout.com for any questions.
