//
//  TransactionQuery.swift
//
//
//  Created by Paul Charnoz on 12/10/2026.
//

import Foundation

/// Describes which page of transactions to retrieve with ``CheckoutCardManager/getTransactions(query:)``.
///
/// Create a query with the filters you need to retrieve the first page, then use the
/// ``TransactionPage/nextPage`` query of each returned page to retrieve the following one.
///
/// The cardholder is always the one of the session token used in ``CheckoutCardManager/logInSession(token:)``,
/// so it cannot be provided here.
///
/// ## Example
///
/// ```swift
/// // Cleared transactions of a card, for the last 30 days
/// let query = TransactionQuery(cardID: card.id,
///                              status: .cleared,
///                              from: Calendar.current.date(byAdding: .day, value: -30, to: Date()))
/// let firstPage = try await cardManager.getTransactions(query: query)
/// ```
///
/// - SeeAlso: ``TransactionPage``, ``Transaction``
public struct TransactionQuery: Equatable {

    /// Number of transactions per page used when none is specified
    public static let defaultPageSize = 20

    /// Largest number of transactions per page supported
    public static let maximumPageSize = 100

    /// Identifier of the card to return the transactions of
    public let cardID: String

    /// Only return transactions with this status
    public let status: TransactionStatus?

    /// Only return transactions created on or after this date
    public let from: Date?

    /// Only return transactions created on or before this date.
    ///
    /// When `nil`, the first page returns the most recent transactions and the following pages are pinned
    /// to the newest transaction of the first page, so transactions created while paging do not shift
    /// the pages. Refresh the list by requesting a first page again.
    public let to: Date?

    /// Maximum number of transactions in a page, between 1 and ``maximumPageSize``
    public let pageSize: Int

    /// Number of transactions already returned by the previous pages of this query
    let skip: Int

    /// Creates a query for the first page of transactions.
    ///
    /// - Parameters:
    ///   - cardID: Identifier of the card to return the transactions of
    ///   - status: Only return transactions with this status. Defaults to all statuses
    ///   - from: Only return transactions created on or after this date
    ///   - to: Only return transactions created on or before this date. Defaults to no upper bound
    ///   - pageSize: Number of transactions per page, clamped between 1 and ``maximumPageSize``.
    ///               Defaults to ``defaultPageSize``
    public init(cardID: String,
                status: TransactionStatus? = nil,
                from: Date? = nil,
                to: Date? = nil,
                pageSize: Int = TransactionQuery.defaultPageSize) {
        self.init(cardID: cardID, status: status, from: from, to: to, pageSize: pageSize, skip: 0)
    }

    init(cardID: String, status: TransactionStatus?, from: Date?, to: Date?, pageSize: Int, skip: Int) {
        self.cardID = cardID
        self.status = status
        self.from = from
        self.to = to
        self.pageSize = min(max(pageSize, 1), Self.maximumPageSize)
        self.skip = skip
    }
}
