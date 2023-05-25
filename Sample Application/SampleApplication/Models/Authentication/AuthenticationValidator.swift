//
//  AuthenticationValidator.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 04/11/2022.
//

import LocalAuthentication

enum AuthenticationValidator {

    // In a real world application this should be replaced by a call in line with your SCA policy

    static func isDeviceOwner(completionHandler: @escaping ((Bool) -> Void)) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication,
                                   localizedReason: "Confirm you can access data",
                                   reply: { outcome, _ in
                completionHandler(outcome)
            })
        } else {
            completionHandler(true)
        }
    }
}
