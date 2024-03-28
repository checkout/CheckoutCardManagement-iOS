![Checkout.com](https://github.com/checkout/frames-ios/blob/main/.github/media/checkout-logo.png)

Checkout.com’s Out-of-Band (OOB) Authentication SDK enables iOS apps to authenticate users for digital transactions (3DS). Our OOB SDK enables you to offer a modern 3DS challenge method alongside existing challenge types, such as OTP. 

OOB involves utilising a secondary factor, such as your phone’s banking app, to authenticate a payment and encompasses the fundamental processes of device binding and transaction authentication. Our OOB SDK is focused on this use case. 

***

# Table of Contents
- [Environments](#Environments)
- [Integration](#Integration)
  - [Import SDK](#Import-SDK)
  - [Register Device](#Register-Device)
  - [Authenticate Payment](#Authenticate-Payment)
- [Other requirements](#Other-requirements)
  - [Building the UI](#Building-the-UI)
  - [Listening to webhooks](#Listening-to-webhooks)
  - [Performing SCA as requested](#Performing-SCA-as-requested)

***

# Environments
The iOS SDK supports the following environments: Sandbox and Production. You’ll define the environment to use when you initialise the SDK. 

To use Sandbox and Production environments, you must have [begun onboarding for card issuing](https://www.checkout.com/docs/card-issuing/get-started-with-issuing) with Checkout.com. During your onboarding, you'll receive client credentials, which you'll need to handle on your back end for authentication to access the environments.

***

# Requirements
- The SDK is provided as a native Swift package. If you're working on a hybrid project, consult your hybrid platform's documentation for instructions on integrating native third-party SDKs.

- It's important to ensure Strong Customer Authentication (SCA) is enabled for your users. While we handle various security measures, you're responsible for performing SCA on your users as specified.

- Each authentication session has the ability to generate multiple tokens simultaneously for various systems. For instance, for sign-in purposes or to obtain an SDK session token or an internal authentication token. However, only one SDK token can be generated from each SCA flow requested.

***
# Integration

### Import SDK
Our SDK is designed to seamlessly integrate with all our backend services for features relevant to OOB authentication. Whether you're registering a device for OOB or authenticating payments via your iOS app, our SDK simplifies the process, making it effortless for you to offer this functionality to your users.

Import the SDK into your app using Swift Package Manager (SPM):

1. Open Xcode and navigate to `Project -> Package Dependencies`.
2. When prompted, enter the URL: https://github.com/checkout/CheckoutCardManagement-iOS.git
3. Select `Up to Next Major Version` as below
<img width="671" alt="1" src="https://github.com/checkout/CheckoutCardManagement-iOS/assets/125963311/c5f244c4-05dc-40f4-a57e-0ae08ed8d3e2">


4. Click on `Add Package`
5. You'll be presented with these options: 
<img width="773" alt="2" src="https://github.com/checkout/CheckoutCardManagement-iOS/assets/125963311/d9805451-57b0-454b-9ff2-efd3e8269f9a">


6. If you just want to use OOB SDK as a standalone SDK and no other product from Checkout.com, select your main target to include `CheckoutOOBSDK` as below. If you also want to use Checkout.com's Issuing solution ([CheckoutCardManagement](https://github.com/checkout/CheckoutCardManagement-iOS)), then follow the instructions in its README. (See an example [here](https://github.com/checkout/CheckoutCardManagement-iOS/tree/main/Sample%20Application))
<img width="768" alt="3" src="https://github.com/checkout/CheckoutCardManagement-iOS/assets/125963311/0a39ab8a-2d3f-4d21-adf4-bb21805a6789">


7. Click on `Add Package` again.
8. You have to add [CheckoutNetwork](https://github.com/checkout/NetworkClient-iOS) as a dependency to your project as well. Use `https://github.com/checkout/NetworkClient-iOS.git` for that
9. For an example, see our [SampleApplication](https://github.com/checkout/CheckoutCardManagement-iOS/tree/main/Sample%20Application)'s configuration under `Project -> Package Dependencies` thereof.
10. Refer to Apple's documentation on adding a SPM dependency for detailed instructions.

To begin utilising the SDK functionality, initialise the primary object, granting access to its features:

```Swift
import CheckoutOOBSDK

// Initialise the SDK with preferred environment
let checkoutOOB = CheckoutOOB(environment: .sandbox)
```

### Register Device
This is the first core flow whereby the device and app must be registered for OOB. Note that a given card can only be registered for OOB for a single device/app combination. If you register another device for the same card it will overwrite the previously bound device/app combination.

The register device stage can likely be done as a background process during onboarding of a user in your iOS app, but you could offer a button that enables a user to do this manually if you wish. Note that before registering a device/app/card combination for OOB, you must perform SCA on the cardholder. 

To establish device binding, register your cardholder's mobile device as follows:

```Swift
// You must be in an async context to call SDK's async functions.
// You can use a Task for that.
Task {
  do {
    let deviceRegistration = try CheckoutOOB.DeviceRegistration(token: "access_token",
                                                                cardID: "card_id", // 30 characters
                                                                applicationID: "application_id", // Most probably your notification token. Communicate with your backend to figure it out.
                                                                phoneNumber: CheckoutOOB.PhoneNumber(countryCode: "+44", number: "5006007080"),
                                                                locale: .english) // Other option is `.french`

    try await checkoutOOB.registerDevice(with: deviceRegistration)

  } catch  {
    print(error.localizedDescription)
  }
}
```

### Authenticate Payment
This is the core authentication flow where the user will approve or reject the transaction within your iOS app. This flow will begin from our card issuing backend, where you will need to listen to the webhook provided to obtain transaction details to inject into the SDK (more on webhooks later).

Note that before authenticating a payment using OOB, you must perform SCA on the cardholder. 


Once you have the data from your backend, verify online card transactions made by your cardholders like so:

```Swift
Task {
  do {
    let paymentAuthentication = try CheckoutOOB.Authentication(token: "access_token",
                                                               cardID: "card_id", // 30 characters
                                                               transactionID: "transaction_id",
                                                               method: .biometrics,
                                                               decision: .accepted)

    try await checkoutOOB.authenticatePayment(with: paymentAuthentication)

    } catch {
      print(error.localizedDescription)
    }
}
```
***

# Other requirements
### Building the UI
Our SDK remains light on UI objects so that you can create the experience you desire. You will therefore need to build the UI for the transaction authentication screen (the screen that shows during the _authenticate payment_ stage), as well as any associated UI (if you wish so) for the _register device_ process.

### Listening to webhooks 
***
(Only read if you are developing the backend support for your application's OOB functionality, if you're solely a mobile developer, disregard this section)
***
In order to obtain transaction information to inject into our SDK, you must be able to listen to webhooks from our issuing backend. We recommend that you implement a push notification to the mobile app and use the data from the webhook to inform the cardholder about the details of the transaction they are authenticating for.

You should provide an endpoint that receives a HTTP POST and returns a 200 OK response on receipt of the webhook. The transaction will not complete unless we receive acknowledgement.

The JSON payload you should expect looks like this:
```json
{
    "acsTransactionId": "bea260bb-c183-4d74-8bc9-421fe3aa2658",
    "cardId": "ea3ze38kfj3g6ktv6wn14aaylvmdv3qn",
    "applicationId": "ios-4283-23344-7884ea-474752",
    "transactionDetails": {
        "maskedCardNumber": "**** **** **** 1234",
        "purchaseDate": "2024-12-24T17:32:28.000Z",
        "merchantName": "ACME Corporation",
        "purchaseAmount": 1,
        "purchaseCurrency": "GBP"
    },
    "threeDSRequestorAppURL": "https://requestor.netcetera.com?transID=bea260bb-c183-4d74-8bc9-421fe3aa2658"
}

```

The _applicationId_ property is used to identify which mobile app to send a push notification to. 

We will also provide a webhook in the event that the transaction is cancelled, due to timeout or any other cause. We also expect a 200 OK acknowledgement for this webhook. In this case, the JSON payload will look like this:

```json
{
    "transactionId": "bea260bb-c183-4d74-8bc9-421fe3aa2658"
}
```

In both cases we will also include an `Authorization` header in the request containing the value provided to us at client onboarding. This is used to verify that the request comes from us.

For any questions on onboarding, please speak to your issuing representative or contact issuing_operations@checkout.com. 

### Performing SCA as requested
You must perform SCA (strong customer authentication) on the cardholder before device registration and payment authentication flows. This would likely be when the user enters the app, but could be at other stages.
