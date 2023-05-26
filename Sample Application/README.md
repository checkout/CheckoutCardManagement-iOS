# Sample Application

Our sample app showcases how to integrate our [Checkout.com's Issuing SDK](https://github.com/checkout/CheckoutCardManagement-iOS)

### How to Use
There are two environments to use; *Stub* and *Live*. The sample app works with Stub by default, whereby Stub returns mocked data for testing purposes. If you want to switch to the Live version, you need to do the following:

 - Search for `AuthenticationCredentials` file and `update all the properties` with your own
 - Go to `Project` -> `Package Dependencies` and then re-add `CheckoutCardManagement`SDK but select the non-stub variation this time
 - 
<img width="648" alt="Screenshot 2023-05-26 at 12 18 40" src="https://github.com/checkout/CheckoutCardManagement-iOS/assets/125963311/341b776c-278d-414e-8bf8-3f471aab668f">

### Where To Look At

You can directly go to `CardListViewModel` and see the SDK calls there.

### Strong Customer Authentication
Where documented, you are required to perform StrongCustomAuthentication (SCA) in accordance to your company's policies and processes.

The sample project integrates directly with CKO backend for token creation in order to enable the flows, but in a live application this is expected to occur from your backend to CKO backend and not be performed via your application.

If you are running the sample application on a simulator, then, before any sensitive operations (`PIN`, `PAN` and`Security Code` reveal), you will be asked for a passcode. To pass that screen, just type anything and hit Enter. If you are using a real device, you will use Face ID, Touch ID, or the device's passcode.

### Other Notes
- `PIN` and `PAN & Security Code` pair should not be visible at the same time, hence they get blurred in a mutually exclusive manner.
- `PIN`can only be visible for 5 seconds. This can be extended or shortened. It's just there to denote the neediness of it.
