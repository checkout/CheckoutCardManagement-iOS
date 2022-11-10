//
//  Card+Pin.swift
//  
//
//  Created by Alex Ioja-Yang on 15/06/2022.
//

import Foundation

public extension Card {
    
    /// Request a secure UI component containing pin number for the card
    func getPin(singleUseToken: String,
                completionHandler: @escaping CheckoutCardManager.SecureResultCompletion) {
        guard let manager = manager else {
            completionHandler(.failure(.missingManager))
            return
        }
//        let pinViewDesign = manager.designSystem.pinViewDesign
//        let startTime = Date()
//        manager.cardService.displayPin(forCard: id,
//                                       displayConfiguration: pinViewDesign,
//                                       singleUseToken: singleUseToken) { [weak self] result in
//            switch result {
//            case .success(let pinView):
//                if let self = self {
//                    let event = LogEvent.getPin(idLast4: self.partIdentifier,
//                                                cardState: self.state)
//                    self.manager?.logger?.log(event, startedAt: startTime)
//                }
//                completionHandler(.success(pinView))
//            case .failure(let error):
//                self?.manager?.logger?.log(.failure(source: "Get Pin", error: error), startedAt: startTime)
//                completionHandler(.failure(.from(error)))
//            }
//        }
    }
    
}
