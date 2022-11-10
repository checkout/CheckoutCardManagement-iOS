//
//  Card+Pan.swift
//  
//
//  Created by Alex Ioja-Yang on 16/06/2022.
//

import Foundation
//import UIKit

public extension Card {
    
    /// Request a secure UI component containing long card number for the card
    func getPan(singleUseToken: String,
                completionHandler: @escaping CheckoutCardManager.SecureResultCompletion) {
        guard let manager = manager else {
            completionHandler(.failure(.missingManager))
            return
        }
//        let panViewDesign = manager.designSystem.panViewDesign
//        let startTime = Date()
//        manager.cardService.displayPan(forCard: id,
//                                       displayConfiguration: panViewDesign,
//                                       singleUseToken: singleUseToken) { [weak self] result in
//            switch result {
//            case .success(let pinView):
//                if let self = self {
//                    let event = LogEvent.getPan(idLast4: self.partIdentifier,
//                                                cardState: self.state)
//                    self.manager?.logger?.log(event, startedAt: startTime)
//                }
//                completionHandler(.success(pinView))
//            case .failure(let error):
//                self?.manager?.logger?.log(.failure(source: "Get Pan", error: error), startedAt: startTime)
//                completionHandler(.failure(.from(error)))
//            }
//        }
    }
    
    /// Request a tuple made of pan and security code protected UI components for the card
    func getPanAndSecurityCode(singleUseToken: String,
                               completionHandler: @escaping CheckoutCardManager.SecurePropertiesResultCompletion) {
        guard let manager = manager else {
            completionHandler(.failure(.missingManager))
            return
        }
//        let panViewDesign = manager.designSystem.panViewDesign
//        let securityCodeDesign = manager.designSystem.securityCodeViewDesign
//        let startTime = Date()
//        manager.cardService.displayPanAndSecurityCode(forCard: id,
//                                                      panViewConfiguration: panViewDesign,
//                                                      securityCodeViewConfiguration: securityCodeDesign,
//                                                      singleUseToken: singleUseToken) { [weak self] result in
//            switch result {
//            case .success(let views):
//                if let self = self {
//                    let event = LogEvent.getPanCVV(idLast4: self.partIdentifier,
//                                                   cardState: self.state)
//                    self.manager?.logger?.log(event, startedAt: startTime)
//                }
//                completionHandler(.success(views))
//            case .failure(let error):
//                self?.manager?.logger?.log(.failure(source: "Get Pan and SecurityCode", error: error), startedAt: startTime)
//                completionHandler(.failure(.from(error)))
//            }
//        }
    }
    
}
