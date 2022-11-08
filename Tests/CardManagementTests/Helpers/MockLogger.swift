//
//  MockLogger.swift
//  
//
//  Created by Alex Ioja-Yang on 12/09/2022.
//

import CheckoutEventLoggerKit

class MockLogger: CheckoutEventLogging {
    
    var receivedLogEvents: [Event] = []

    func log(event: Event) {
        receivedLogEvents.append(event)
    }

    // Not implemented, added for conformity
    func add(metadata: String, value: String) {
    }

    func remove(metadata: String) {
    }

    func clearMetadata() {
    }

    func enableLocalProcessor(monitoringLevel: CheckoutEventLoggerKit.MonitoringLevel) {
    }

    func enableRemoteProcessor(environment: CheckoutEventLoggerKit.Environment, remoteProcessorMetadata: CheckoutEventLoggerKit.RemoteProcessorMetadata) {
    }
}
