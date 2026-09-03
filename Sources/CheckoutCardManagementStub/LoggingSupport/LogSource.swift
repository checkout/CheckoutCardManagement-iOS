//
//  LogSource.swift
//
//

import Foundation

/// Labels used as `source:` values on `LogEvent.failure`.
enum LogSource {
    static let getPan = "Get Pan"
    static let getSecurityCode = "Get Security Code"
    static let getPanAndSecurityCode = "Get Pan and SecurityCode"
    static let copyPan = "Copy Pan"
    static let copySecurityCode = "Copy Security Code"
}
