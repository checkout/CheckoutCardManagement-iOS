//
//  CheckoutCardManager+Transactions.swift
//
//
//  Created by Paul Charnoz on 12/10/2026.
//

import Foundation
import CheckoutCardNetworkStub

extension CheckoutCardManager {

    /// Retrieves a page of transactions of a card of the authenticated cardholder.
    ///
    /// Transactions are returned newest first. Only the transactions of the cardholder of the session token
    /// are returned: the scope is enforced by the server from the token, and cannot be widened by the app.
    /// Use the query to narrow the list down, e.g. to a status or a date range.
    ///
    /// To page through the list, pass the ``TransactionPage/nextPage`` query of a page to retrieve the next one.
    /// The following pages pin the end of the date range to the newest transaction of the first page, so
    /// transactions created while paging do not shift them. To show newly created transactions, request
    /// a first page again.
    ///
    /// **Important:** This method requires an active session. You must call ``logInSession(token:)`` with a
    /// valid session token before invoking this method. The token must grant the `issuing:transactions-read` scope.
    ///
    /// - Parameter query: Card, filters and page size of the list
    /// - Returns: A ``TransactionPage`` with the transactions, and the query for the next page if any
    /// - Throws: ``CardManagementError`` indicating the failure reason:
    ///   - ``CardManagementError/unauthenticated`` if no session is active, or the session token was rejected,
    ///     has expired or does not grant access to transactions
    ///   - ``CardManagementError/invalidRequestInput`` if no request could be built from the query
    ///   - ``CardManagementError/notFound`` if the requested resource could not be found
    ///   - ``CardManagementError/connectionIssue`` if there are network connectivity problems or server communication errors
    ///   - ``CardManagementError/configurationIssue(hint:)`` if the SDK is misconfigured or the request parameters are invalid (check the hint property for guidance)
    ///
    /// ## Example
    ///
    /// ```swift
    /// var transactions: [Transaction] = []
    /// var nextPage: TransactionQuery? = TransactionQuery(cardID: card.id)
    ///
    /// // Call when the user reaches the end of the list
    /// func loadMore() async throws {
    ///     guard let query = nextPage else { return }
    ///     let page = try await cardManager.getTransactions(query: query)
    ///     transactions += page.transactions
    ///     nextPage = page.nextPage
    /// }
    /// ```
    ///
    /// - SeeAlso: ``Transaction``, ``TransactionQuery``, ``TransactionPage``, ``logInSession(token:)``
    public func getTransactions(query: TransactionQuery) async throws -> TransactionPage {
        guard let sessionToken = sessionToken else {
            throw CardManagementError.unauthenticated
        }

        let startTimestamp = Date()
        let request = TransactionListRequest(cardID: query.cardID,
                                             status: query.status,
                                             from: query.from,
                                             to: query.to,
                                             limit: query.pageSize,
                                             skip: query.skip)

        do {
            let response = try await cardService.getTransactions(sessionToken: sessionToken, request: request)
            let page = TransactionPage(transactions: response.data,
                                       totalCount: response.totalCount,
                                       nextPage: nextPage(after: query, response: response))

            logger?.log(.transactionList(cardID: query.cardID,
                                         transactionCount: page.transactions.count,
                                         pageSize: query.pageSize),
                        startedAt: startTimestamp)
            return page
        } catch let error as CardNetworkError {
            logger?.log(
                .failure(source: "Get Transactions",
                         error: error,
                         networkError: error,
                         additionalInfo: [:]),
                startedAt: startTimestamp
            )
            throw CardManagementError.from(error)
        } catch {
            logger?.log(
                .failure(source: "Get Transactions",
                         error: error,
                         additionalInfo: [:]),
                startedAt: startTimestamp
            )

            throw CardManagementError.connectionIssue
        }
    }

    /// Query replaying the same filters and date range, skipping the transactions already returned
    ///
    /// Without an end date, the first page lets the server bound the range to its current time, and the
    /// following pages are pinned to the newest transaction of the first page. Pinning to a server-provided
    /// date rather than the device clock keeps the pages stable even when the device clock is off.
    private func nextPage(after query: TransactionQuery, response: TransactionListResponse) -> TransactionQuery? {
        let returnedCount = query.skip + response.data.count
        guard let newestCreatedOn = response.data.map(\.createdOn).max(),
              returnedCount < response.totalCount else {
            return nil
        }
        // The date is sent with millisecond precision: add a millisecond so the newest
        // transaction is still included in the range, whatever the server precision
        return TransactionQuery(cardID: query.cardID,
                                status: query.status,
                                from: query.from,
                                to: query.to ?? newestCreatedOn.addingTimeInterval(0.001),
                                pageSize: query.pageSize,
                                skip: returnedCount)
    }
}
