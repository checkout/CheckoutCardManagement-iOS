//
//  CheckoutLogger.swift
//  
//
//  Created by Alex Ioja-Yang on 12/09/2022.
//

import Foundation
@preconcurrency import CheckoutEventLoggerKit
import CheckoutCardNetwork

final class CheckoutLogger: NetworkLogger {
    let sessionID: String
    private let eventLogger: CheckoutEventLogging

    init(eventLogger: CheckoutEventLogging) {
        self.sessionID = UUID().uuidString
        self.eventLogger = eventLogger
    }

    /// Convenience method wrapping formatting from project specific Event format to generic SDK expectation
    func log(_ event: LogEvent, startedAt date: Date? = nil) {
        eventLogger.log(event: LogFormatter.build(event: event, startedAt: date))
    }

    /// Network Logger conformance, enabling to collect network level details if error is encountered
    func log(error: Error, additionalInfo: [String: String]) {
        let event = LogEvent.failure(source: additionalInfo["source"] ?? "", error: error, additionalInfo: additionalInfo)
        eventLogger.log(event: LogFormatter.build(event: event,
                                                extraProperties: additionalInfo))
    }
    
    /// Enable logger to dispatch events
    func setupRemoteLogging(environment: CardManagerEnvironment,
                            serviceVersion: CardServiceVersion) {
        let networkVersion = "\(serviceVersion.name)-\(serviceVersion.number)"
        let loggingMetadata = RemoteProcessorMetadata(productIdentifier: Constants.productName,
                                                      productVersion: networkVersion,
                                                      environment: environment.rawValue)
        eventLogger.enableRemoteProcessor(environment: environment.loggingEnvironment(),
                                          remoteProcessorMetadata: loggingMetadata)

        eventLogger.add(metadata: Constants.sessionIDKey, value: sessionID)
    }

}
