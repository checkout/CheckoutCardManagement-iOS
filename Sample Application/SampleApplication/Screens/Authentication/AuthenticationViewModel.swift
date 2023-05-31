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
    @Published var errorMessage: String?

    private let authenticator: Authenticator

    init(authenticator: Authenticator = .init()) {
        self.authenticator = authenticator
    }
}

extension AuthenticationViewModel {
    func authenticateButtonTapped() {
        viewState = .loading

        authenticator.authenticateUser(performSCA: false) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let accessToken):

                    self.authenticationRecord.state = .authenticated(accessToken: accessToken)
                    self.viewState = .loaded

                case .failure(let error):
                    self.authenticationRecord.state = .notAuthenticated
                    self.errorMessage = error.localizedDescription
                    self.viewState = .initial
                }
            }
        }
    }

    func errorMessageTapped() {
        errorMessage = nil
    }
}
