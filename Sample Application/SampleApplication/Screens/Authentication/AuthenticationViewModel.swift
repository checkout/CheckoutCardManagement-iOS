//
//  AuthenticationViewModel.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 20/07/2022.
//

import Foundation

#if canImport(CheckoutCardManagement)
import CheckoutCardManagement
#elseif canImport(CheckoutCardManagementStub)
import CheckoutCardManagementStub
#endif

final class AuthenticationViewModel: ObservableObject {
    enum ViewState {
        case initial
        case loading
        case loaded
    }

    @Published var viewState: ViewState = .initial
    @Published var authenticationRecord: AuthenticationRecord = .init()

    private let authenticator: Authenticator

    init(authenticator: Authenticator = .init()) {
        self.authenticator = authenticator
    }
}

extension AuthenticationViewModel {
    func authenticateButtonTapped() {
        viewState = .loading

        authenticator.authenticateUser(checkDeviceOwnership: false) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let accessToken):

                    self.authenticationRecord.state = .authenticated(accessToken: accessToken)
                    self.viewState = .loaded

                case .failure:
                    self.authenticationRecord.state = .notAuthenticated
                }
            }
        }
    }
}
