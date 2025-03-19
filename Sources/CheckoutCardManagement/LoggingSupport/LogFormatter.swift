//
//  LogFormatter.swift
//  
//
//  Created by Alex Ioja-Yang on 12/09/2022.
//

import Foundation
import CheckoutEventLoggerKit

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
        case .cardList(let suffixes):
            dictionary = ["suffix_ids": AnyCodable(suffixes)]
        case .getPin(let idLast4, let state),
                .getPan(let idLast4, let state),
                .getCVV(let idLast4, let state),
                .getPanCVV(let idLast4, let state):
            dictionary = [
                "suffix_id": AnyCodable(idLast4),
                "card_state": AnyCodable(state.rawValue)
            ]
        case .stateManagement(let idLast4, let originalState, let requestedState, let reason):
            dictionary = [
                "suffix_id": AnyCodable(idLast4),
                "from": AnyCodable(originalState.rawValue),
                "to": AnyCodable(requestedState.rawValue)
            ]
            if let reason {
                dictionary["reason"] = AnyCodable(reason)
            }
        case .configurePushProvisioning(let last4CardholderID):
            dictionary = [
                "cardholder": AnyCodable(last4CardholderID)
            ]
        case .getCardDigitizationState(let last4CardID, let digitizationState):
            dictionary = [
                "card": AnyCodable(last4CardID),
                "digitization_state": AnyCodable(digitizationState.rawValue)
            ]
        case .pushProvisioning(let last4CardID):
            dictionary = [
                "card": AnyCodable(last4CardID)
            ]
        case .failure(let source, let error):
            dictionary = [
                "source": AnyCodable(source),
                "error": AnyCodable(error.localizedDescription)
            ]
        }
        dictionary.addTimeSince(startDate: startDate)
        return dictionary
    }
}
