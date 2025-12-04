//
//  LogFormatter.swift
//  
//
//  Created by Alex Ioja-Yang on 12/09/2022.
//

import Foundation
import CheckoutEventLoggerKit
import CheckoutCardNetworkStub

/// Formatter for internal Analytic Events
enum LogFormatter {

    private static let typePrefix = "com.checkout.issuing-mobile-sdk."

    /// Create dispatchable analytics event from the given LogEvent
    static func build(event: LogEvent,
                      startedAt startDate: Date? = nil,
                      extraProperties: [String: String] = [:]) -> Event {
        var eventProperties = properties(from: event, startDate: startDate)
        extraProperties.forEach {
            eventProperties[$0.key] = AnyCodable($0.value)
        }
        return Event(typeIdentifier: typePrefix + identifier(for: event),
              time: Date(),
              monitoringLevel: monitoringLevel(for: event),
              properties: eventProperties)
    }

    /// Define unique identifier for event
    static private func identifier(for event: LogEvent) -> String {
        switch event {
        case .initialized: return "card_management_initialised"
        case .cardList: return "card_list"
        case .getPin: return "card_pin"
        case .getPan: return "card_pan"
        case .getCVV: return "card_cvv"
        case .getPanCVV: return "card_pan_cvv"
        case .stateManagement: return "card_state_change"
        case .configurePushProvisioning: return "configure_push_provisioning"
        case .getCardDigitizationState: return "get_card_digitization_state"
        case .pushProvisioning: return "push_provisioning"
        case .failure: return "failure"
        case .copyPan: return "copy_pan"
        case .cardDetails: return "card_details"
        }
    }

    /// Define monitoring level for event
    static private func monitoringLevel(for event: LogEvent) -> MonitoringLevel {
        switch event {
        case .initialized,
                .cardList,
                .getPin,
                .getPan,
                .getCVV,
                .getPanCVV,
                .stateManagement,
                .configurePushProvisioning,
                .getCardDigitizationState,
                .copyPan,
                .cardDetails,
                .pushProvisioning:
            return .info
        case .failure:
            return .warn
        }
    }

    /// Generate dictionary of properties  for event
    static private func properties(from event: LogEvent, startDate: Date? = nil) -> [String: AnyCodable] {
        var dictionary = [String: AnyCodable]()
        switch event {
        case .initialized(let design):
            dictionary = [
                "version": AnyCodable(Constants.productVersion),
                "design": AnyCodable(try? design.mapToLogDictionary())
            ]
        case .cardList(let cardIds):
            dictionary = ["cardIds": AnyCodable(cardIds)]
        case .cardDetails(let cardID):
            dictionary = ["cardId": AnyCodable(cardID)]
        case .getPin(let cardId, let state),
                .getPan(let cardId, let state),
                .getCVV(let cardId, let state),
                .getPanCVV(let cardId, let state),
                .copyPan(let cardId, let state):
            dictionary = [
                "cardId": AnyCodable(cardId),
                "card_state": AnyCodable(state.rawValue)
            ]
        case .stateManagement(let cardId, let originalState, let requestedState, let reason):
            dictionary = [
                "cardId": AnyCodable(cardId),
                "from": AnyCodable(originalState.rawValue),
                "to": AnyCodable(requestedState.rawValue)
            ]
            if let reason {
                dictionary["reason"] = AnyCodable(reason)
            }
        case .configurePushProvisioning(let cardholderId):
            dictionary = [
                "cardholder": AnyCodable(cardholderId)
            ]
        case .getCardDigitizationState(let cardId, let digitizationState):
            dictionary = [
                "card": AnyCodable(cardId),
                "digitization_state": AnyCodable(digitizationState.rawValue)
            ]
        case .pushProvisioning(let cardId):
            dictionary = [
                "cardId": AnyCodable(cardId)
            ]
        case .failure(let source, let error, let networkError, let additionalInfo):
            if let networkError = networkError {
                let errorDetails = extractErrorDetails(from: networkError)
                dictionary = [
                    "source": AnyCodable(source),
                    "error_type": AnyCodable(errorDetails.type),
                    "error_description": AnyCodable(errorDetails.description)
                ]

                if let additionalErrorInfo = errorDetails.additionalInfo {
                    additionalErrorInfo.forEach { key, value in
                        dictionary["error_\(key)"] = AnyCodable(value)
                    }
                }
            } else {
                dictionary = [
                    "source": AnyCodable(source),
                    "error": AnyCodable(error.localizedDescription)
                ]
            }

            additionalInfo.forEach { (key: String, value: Any) in
                dictionary[key] = AnyCodable(value)
            }
        }
        dictionary.addTimeSince(startDate: startDate)
        return dictionary
    }

    /// Extract structured information from CardNetworkError
    private static func extractErrorDetails(from error: Error) -> (type: String, description: String, additionalInfo: [String: Any]?) {
        guard let cardNetworkError = error as? CardNetworkError else {
            return (type: "unknown", description: error.localizedDescription, additionalInfo: nil)
        }

        switch cardNetworkError {
        case .authenticationFailure:
            return (type: "authentication_failure", description: "Authentication failed", additionalInfo: nil)

        case .deviceNotSupported:
            return (type: "device_not_supported", description: "Device does not support the operation", additionalInfo: nil)

        case .insecureDevice:
            return (type: "insecure_device", description: "Device flagged as unsafe", additionalInfo: nil)

        case .invalidRequest(let hint):
            return (type: "invalid_request", description: "Invalid request", additionalInfo: ["hint": hint])

        case .invalidRequestInput:
            return (type: "invalid_request_input", description: "Invalid request input format", additionalInfo: nil)

        case .misconfigured(let hint):
            return (type: "misconfigured", description: "Service connection misconfigured", additionalInfo: ["hint": hint])

        case .serverIssue:
            return (type: "server_issue", description: "Server unable to respond", additionalInfo: nil)

        case .unauthenticated:
            return (type: "unauthenticated", description: "Session expired or missing", additionalInfo: nil)

        case .secureOperationsFailure:
            return (type: "secure_operations_failure", description: "Unable to handle secure operations", additionalInfo: nil)

        case .parsingFailure:
            return (type: "parsing_failure", description: "Response format mismatch", additionalInfo: nil)

        case .pushProvisioningFailure(let failure):
            let failureType = extractPushProvisioningFailureType(failure)
            return (type: "push_provisioning_failure", description: "Push provisioning failed", additionalInfo: ["failure_type": failureType])

        case .fetchDigitizationStateFailure(let failure):
            let failureType = extractDigitizationStateFailureType(failure)
            return (type: "fetch_digitization_state_failure", description: "Failed to fetch digitization state", additionalInfo: ["failure_type": failureType])
        case .unableToCopy(let failure):
            let failureType = extractUnableToCopyFailureType(failure)
            return (type: "copy_failure", description: "Failed to copy to clipboard", additionalInfo: ["failure_type": failureType])
        }
    }

    /// Extract push provisioning failure type
    private static func extractPushProvisioningFailureType(_ failure: CardNetworkError.PushProvisioningFailure) -> String {
        switch failure {
        case .cancelled:
            return "cancelled"
        case .configurationFailure:
            return "configuration_failure"
        case .operationFailure(let hint):
            return "operation_failure \(hint)"
        }
    }

    /// Extract digitization state failure type
    private static func extractDigitizationStateFailureType(_ failure: CardNetworkError.DigitizationStateFailure) -> String {
        switch failure {
        case .configurationFailure:
            return "configuration_failure"
        case .operationFailure:
            return "operation_failure"
        }
    }

    /// Extract digitization state failure type
    private static func extractUnableToCopyFailureType(_ failure: CardNetworkError.CopySensitiveDataError) -> String {
        switch failure {
        case .copyFailure:
            return "copy_operation_failure"
        case .dataNotViewed:
            return "pan_not_viewed"
        }
    }
}
