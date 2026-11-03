//
//  TransactionPage.swift
//
//
//  Created by Paul Charnoz on 12/10/2026.
//

import Foundation

/// A page of transactions returned by ``CheckoutCardManager/getTransactions(query:)``.
///
/// - SeeAlso: ``TransactionQuery``, ``Transaction``
public struct TransactionPage: Equatable {

    /// Transactions of the page, newest first. Empty when no transaction matches the query
    public let transactions: [Transaction]

    /// Number of transactions matching the query across all pages
    ///
    /// - Note: The server caps this count to the number of transactions it can page through
    public let totalCount: Int

    /// Query to retrieve the page following this one, `nil` when this is the last page
    public let nextPage: TransactionQuery?

    /// Whether more transactions can be retrieved with ``nextPage``
    public var hasMore: Bool { nextPage != nil }

    init(transactions: [Transaction], totalCount: Int, nextPage: TransactionQuery?) {
        self.transactions = transactions
        self.totalCount = totalCount
        self.nextPage = nextPage
    }
}
