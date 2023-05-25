# Sample Application

Sample app that showcases the integration of [Checkout.com's Issuing SDK](https://github.com/checkout/CheckoutCardManagement-iOS)

### How to Use
There are two environments to use; Stub and Live. This sample app works with Stub by default. So, the results you get are just some stubbed data. If you want to switch to the Live version, you need to do:

 - Search for `AuthenticationCredentials` file and update all the properties with your own
 - Go to `Project` -> `Package Dependencies` and then re-add `CheckoutCardManagement`SDK but select the non-stub variation this time

That's it. You're ready to see the live data.

### Where To Look At

You can directly go to `CardListViewModel` and see the SDK calls in thereof.

### Strong Customer Authentication
Where documented, you are required to perform StrongCustomAuthentication (SCA) in accordance to your company's policies and processes.

The sample project integrates directly with CKO backend for token creation in order to enable the flows, but in a live application this is expected to occur from your backend to CKO backend and not be performed via your application.

If you are running the sample application on a simulator, then, before any sensitive operation (`PIN`, `PAN` and`Security Code` reveal), you will be asked for a passcode. You can just type anything and hit `Enter` to pass that screen. On a real device, you will either use Face ID, Touch ID or the device passcode itself.

### Other Notes
- `PIN` and `PAN & Security Code` pair can not be visible at the same time, hence they get blurred in a mutually exclusive manner
- `PIN`can only be visible for 5 seconds. This can be extended or shortened. It's just there to denote the neediness of it.
