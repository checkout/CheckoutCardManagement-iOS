// 
//  CardListViewModel.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 16/03/2023.
//

import UIKit

#if canImport(CheckoutCardManagement)
import CheckoutCardManagement
#elseif canImport(CheckoutCardManagementStub)
import CheckoutCardManagementStub
#endif

final class CardListViewModel: ObservableObject {
    @Published var cardListStackSpace = CardListViewModel.cardOverlappingOffset(hasSelectedCard: false)
    @Published private(set) var authenticationRecord: AuthenticationRecord = .init()

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var showDestructiveActionDialog: Bool = false
    private var destructiveCompletionHandler: (() -> Void)?

    @Published var cards: [Card] = []
    @Published private(set) var selectedCardID: String?

    @Published var showAuthentication: Bool = false
    @Published var panAndSecurityCode: (UIView, UIView)?
    @Published var pin: UIView?

    @Published var showPinSheet = false {
        willSet {
            panAndSecurityCode = .none
        }
    }

    var selectedCard: Card? {
        return cards.first(where: { $0.id == selectedCardID })
    }

    private let cardManager: CheckoutCardManager
    private let authenticator: Authenticator

    init(cardManager: CheckoutCardManager,
         authenticator: Authenticator = .init()) {
        self.cardManager = cardManager
        self.authenticator = authenticator

        authenticationUpdate()
    }
}

// MARK: Card List View Model Operations

extension CardListViewModel {
    private func fetchCards(with accessToken: String) {
        isLoading = true

        guard cardManager.logInSession(token: accessToken) else {
            errorMessage = Constants.String.couldNotLogin
            return
        }

        cardManager.getCards { [weak self] result in

            DispatchQueue.main.async {
                guard let self else { return }

                defer {
                    self.isLoading = false
                }

                switch result {
                case .success(let cards):
                    self.cards = cards

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: Card List View Model Inputs

extension CardListViewModel {
    func authenticationUpdate() {
        if case .authenticated(let token) = authenticationRecord.state {
            fetchCards(with: token)
        } else {
            showAuthentication = authenticationRecord.state == .notAuthenticated
        }
    }

    func errorMessageTapped() {
        errorMessage = nil
    }

    func cardSelected(_ card: Card) {
        if selectedCardID == nil {
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                cards.remove(at: index)
                cards.insert(card, at: 0)
            }
            selectedCardID = card.id
            cardListStackSpace = CardListViewModel.cardOverlappingOffset(hasSelectedCard: true)
        } else {
            selectedCardID = nil
            cardListStackSpace = CardListViewModel.cardOverlappingOffset(hasSelectedCard: false)
            resetCardDetail()
        }
    }

    private func resetCardDetail() {
        panAndSecurityCode = nil
        pin = nil
    }
}

extension CardListViewModel: CardDetailViewDelegate {
    func getPanAndSecurityCodeTapped(completion: @escaping () -> Void) {
        guard let selectedCard else {
            assertionFailure("Can't get pin when a card is not selected")
            return
        }

        getSingleUseToken { accessToken in
            guard let accessToken else { return }

            selectedCard.getPanAndSecurityCode(singleUseToken: accessToken) { [weak self] result in
                DispatchQueue.main.async {
                    defer {
                        completion()
                    }

                    switch result {
                    case let .success(views):
                        self?.panAndSecurityCode = views

                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    func showPinTapped(completion: @escaping () -> Void) {
        guard let selectedCard else {
            assertionFailure("Can't get pin when a card is not selected")
            return
        }

        getSingleUseToken { accessToken in
            guard let accessToken else { return }

            selectedCard.getPin(singleUseToken: accessToken) { [weak self] result in

                DispatchQueue.main.async {
                    defer {
                        completion()
                    }

                    switch result {
                    case .success(let view):
                        guard let self else { return }

                        self.pin = view
                        self.showPinSheet = true

                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            self.showPinSheet = false
                            self.pin = nil
                        }

                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    func changeCardState(to newState: CardState, completion: @escaping () -> Void) {
        guard let selectedCard else {
            assertionFailure("A card does not appear to be selected")
            return
        }

        switch newState {
        case .active:
            selectedCard.activate(completionHandler: cardStateChangeCompletion(completion: completion))
        case .suspended:
            selectedCard.suspend(reason: nil, completionHandler: cardStateChangeCompletion(completion: completion))
        case .revoked:
            destructiveCompletionHandler = completion
            showDestructiveActionDialog = true
        default:
            assertionFailure("Invalid state requested")
        }
    }

    func revokeCard() {
        guard let selectedCard,
              let destructiveCompletionHandler else {
            assertionFailure("A card does not appear to be selected")
            return
        }

        self.destructiveCompletionHandler = nil
        selectedCard.revoke(reason: nil, completionHandler: cardStateChangeCompletion(completion: destructiveCompletionHandler))
    }

    func revokeCancelled() {
        destructiveCompletionHandler?()
        destructiveCompletionHandler = nil
    }

    private func cardStateChangeCompletion(completion: @escaping () -> Void) -> (_ result: CheckoutCardManager.OperationResult) -> Void {
        return { [weak self] result in
            DispatchQueue.main.async {
                defer {
                    completion()
                }

                switch result {
                case .success:
                    guard let self else { return }
                    self.cards = self.cards

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func addToWallet() {
        errorMessage = Constants.String.contactUs
    }
}

extension CardListViewModel {
    private func getSingleUseToken(completionHandler: @escaping (String?) -> Void) {
        authenticator.authenticateUser { [weak self] result in

            switch result {
            case .success(let accessToken):
                completionHandler(accessToken)

            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    completionHandler(nil)
                }
            }
        }
    }
}

extension CardListViewModel {
    enum Constants {
        enum String {
            static let couldNotLogin = "Could not login with the current credentials"
            static let contactUs = "To use this feature, please contact us"
        }
    }
}
