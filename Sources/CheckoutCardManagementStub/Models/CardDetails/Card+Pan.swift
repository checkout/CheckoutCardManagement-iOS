//
//  Card+Pan.swift
//
//
//  Created by Alex Ioja-Yang on 16/06/2022.
//

import Foundation

public extension Card {

    /// Request a secure UI component containing long card number for the card
    func getPan(singleUseToken: String,
                completionHandler: @escaping CheckoutCardManager.SecureResultCompletion) {
        guard let manager = manager else {
            completionHandler(.failure(.missingManager))
            return
        }
        let panViewDesign = manager.designSystem.panViewDesign
        let startTime = Date()
        manager.cardService.displayPan(forCard: id,
                                       displayConfiguration: panViewDesign,
                                       singleUseToken: singleUseToken) { [weak self] result in
            switch result {
            case .success(let pinView):
                if let self = self {
                    let event = LogEvent.getPan(cardId: self.id,
                                                cardState: self.state)
                    self.manager?.logger?.log(event, startedAt: startTime)
                }
                completionHandler(.success(pinView))
            case .failure(let error):
                self?.manager?.logger?.log(
                    .failure(source: "Get Pan",
                             error: error,
                             networkError: error,
                             additionalInfo: ["cardId": self?.id ?? ""]),
                    startedAt: startTime
                )
                completionHandler(.failure(.from(error)))
            }
        }
    }

    /// Asynchronously retrieves and copies the card's Primary Account Number (PAN).
    ///
    /// This method uses a single-use token to securely authorize the copy operation. It delegates the
    /// request to the underlying card service and logs the outcome of the attempt, whether successful or not.
    /// The result is returned asynchronously via the completion handler.
    ///
    /// - Parameters:
    ///   - singleUseToken: A short-lived, single-use token required to authorize the PAN retrieval.
    ///   - completionHandler: A closure executed upon completion. It receives a `CardDetailCopyResult`
    ///                      indicating either success or the reason for failure.
    func copyPan(singleUseToken: String,
                 completionHandler: @escaping ((CheckoutCardManager.CardDetailCopyResult) -> Void)) {
        guard let manager = manager else {
            completionHandler(.failure(.unableToCopy(failure: .missingManager)))
            return
        }

        let startTime = Date()
        manager.cardService.copyPan(forCard: id, singleUseToken: singleUseToken) { [weak self] result in
            guard let self else { return }

            let logEvent: LogEvent
            let completionResult: CheckoutCardManager.CardDetailCopyResult

            switch result {
            case .success:
                logEvent = .copyPan(cardId: self.id, cardState: self.state)
                completionResult = .success
            case .failure(let error):
                logEvent = .failure(source: "Copy Pan",
                                    error: error,
                                    networkError: error,
                                    additionalInfo: ["cardId": self.id])
                completionResult = .failure(.from(error))
            }

            self.manager?.logger?.log(logEvent, startedAt: startTime)
            completionHandler(completionResult)
        }
    }

    /// Request a tuple made of pan and security code protected UI components for the card
    func getPanAndSecurityCode(singleUseToken: String,
                               completionHandler: @escaping CheckoutCardManager.SecurePropertiesResultCompletion) {
        guard let manager = manager else {
            completionHandler(.failure(.missingManager))
            return
        }
        let panViewDesign = manager.designSystem.panViewDesign
        let securityCodeDesign = manager.designSystem.securityCodeViewDesign
        let startTime = Date()
        manager.cardService.displayPanAndSecurityCode(forCard: id,
                                                      panViewConfiguration: panViewDesign,
                                                      securityCodeViewConfiguration: securityCodeDesign,
                                                      singleUseToken: singleUseToken) { [weak self] result in
            switch result {
            case .success(let views):
                if let self = self {
                    let event = LogEvent.getPanCVV(cardId: self.id,
                                                   cardState: self.state)
                    self.manager?.logger?.log(event, startedAt: startTime)
                }
                completionHandler(.success(views))
            case .failure(let error):
                self?.manager?.logger?.log(
                    .failure(source: "Get Pan and SecurityCode",
                             error: error,
                             networkError: error,
                             additionalInfo: ["cardId": self?.id ?? ""]),
                    startedAt: startTime
                )
                completionHandler(.failure(.from(error)))
            }
        }
    }

}
