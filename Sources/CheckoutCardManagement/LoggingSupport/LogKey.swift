//
//  LogKey.swift
//
//

import Foundation

/// Dictionary keys used in `additionalInfo` payloads on `LogEvent.failure`.
enum LogKey {
    static let cardId = "cardId"
    static let errorMessage = "errorMessage"
}
