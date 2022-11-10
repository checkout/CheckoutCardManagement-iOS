//
//  Card+SecurityCode.swift
//  
//
//  Created by Alex Ioja-Yang on 02/11/2022.
//

import Foundation

public extension Card {
    
    /// Request a secure UI component containing security number for the card
    func getSecurityCode(singleUseToken: String,
                         completionHandler: @escaping CheckoutCardManager.SecureResultCompletion) {
        guard let manager = manager else {
            completionHandler(.failure(.missingManager))
            return
        }
//        let securityCodeViewDesign = manager.designSystem.securityCodeViewDesign
        let startTime = Date()
//        manager.cardService.displaySecurityCode(forCard: id,
//                                                displayConfiguration: securityCodeViewDesign,
//                                                singleUseToken: singleUseToken) { [weak self] result in
//            switch result {
//            case .success(let pinView):
//                if let self = self {
//                    let event = LogEvent.getCVV(idLast4: self.partIdentifier,
//                                                cardState: self.state)
//                    self.manager?.logger?.log(event, startedAt: startTime)
//                }
//                completionHandler(.success(pinView))
//            case .failure(let error):
//                self?.manager?.logger?.log(.failure(source: "Get Security Code", error: error), startedAt: startTime)
//                completionHandler(.failure(.from(error)))
//            }
//        }
    }
    
}
