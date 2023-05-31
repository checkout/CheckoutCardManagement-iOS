// 
//  AuthenticationView.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 20/03/2023.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var isCircleSpinning: Bool = false
    @State private var isUnlocked: Bool = false
    
    @ObservedObject private var viewModel: AuthenticationViewModel
    @EnvironmentObject private var authenticationRecord: AuthenticationRecord
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer(minLength: Constants.Size.spacer)
                Text(Constants.Strings.authenticationRequired)
                    .font(Font(DesignSystem.Font.boldTitle))
                    .multilineTextAlignment(.center)
                Spacer(minLength: Constants.Size.spacer)
                
                switch viewModel.viewState {
                case .initial:
                    viewGroup(shouldCircleSpin: false,
                              shouldUnlock: false,
                              buttonText: Constants.Strings.authenticate,
                              buttonAction: viewModel.authenticateButtonTapped)
                    
                case .loading:
                    viewGroup(shouldCircleSpin: true,
                              shouldUnlock: false,
                              buttonText: Constants.Strings.authenticating)
                    
                case .loaded:
                    viewGroup(shouldCircleSpin: false,
                              shouldUnlock: true,
                              buttonText: Constants.Strings.authenticated,
                              animationsCompleted: {
                        dismiss()
                    })
                }
            }
            .onAppear {
                updateViewModel()
            }
            
            if let message = viewModel.errorMessage {
                errorView(message: message)
            }
        }
    }
    
    @ViewBuilder
    private func viewGroup(shouldCircleSpin: Bool,
                           shouldUnlock: Bool,
                           buttonText: String,
                           buttonAction: (() -> Void)? = nil,
                           animationsCompleted: (() -> Void)? = nil) -> some View {
        
        ZStack {
            SpinningCircleView(isAnimating: $isCircleSpinning)
                .onAppear {
                    isCircleSpinning = shouldCircleSpin
                }
            
            LockView(isUnlocked: $isUnlocked,
                     animationsCompleted: animationsCompleted)
            .onAppear {
                isUnlocked = shouldUnlock
            }
        }
        
        Button(action: buttonAction ?? {}) {
            Text(buttonText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.disabled(buttonAction == nil)
            .frame(height: 50, alignment: .center)
            .frame(maxWidth: .infinity)
            .background(Color(DesignSystem.AuthenticationScreenDesign.buttonBackgroundColor))
            .foregroundColor(Color(DesignSystem.AuthenticationScreenDesign.buttonTextColor))
            .font(Font(DesignSystem.Font.boldSubtitle))
            .cornerRadius(25)
            .padding(32)
    }
    
    private func updateViewModel() {
        viewModel.authenticationRecord = authenticationRecord
    }
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack {
            ErrorView(text: message)
            Spacer()
        }
        .onTapGesture {
            viewModel.errorMessageTapped()
        }
    }
}

extension AuthenticationView {
    enum Constants {
        enum Strings {
            static let authenticationRequired = "Authentication \n Required"
            static let authenticate = "Authenticate"
            static let authenticating = "Authenticating..."
            static let authenticated = "Authenticated"
        }
        
        enum Size {
            static let spacer: CGFloat = 35
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    @State static var authenticationRecord: AuthenticationRecord = .init()
    
    static var previews: some View {
        AuthenticationView(viewModel: AuthenticationViewModel())
            .environmentObject(authenticationRecord)
    }
}
