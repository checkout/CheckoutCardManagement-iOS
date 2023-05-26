//
//  CardDetailView.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 20/04/2023.
//

import SwiftUI

#if canImport(CheckoutCardManagement)
import CheckoutCardManagement
#elseif canImport(CheckoutCardManagementStub)
import CheckoutCardManagementStub
#endif

protocol CardDetailViewDelegate: AnyObject {
    func getPanAndSecurityCodeTapped(completion: @escaping () -> Void)
    func showPinTapped(completion: @escaping () -> Void)
    func changeCardState(to newState: CardState, completion: @escaping () -> Void)
    func addToWallet()
}

struct CardDetailView: View {
    @Binding var panAndSecurityCode: (UIView, UIView)?

    @State private var isPanAndSecurityCodeLoading: Bool = false
    @State private var isPinLoading: Bool = false
    @State private var isActivating: Bool = false
    @State private var isSuspending: Bool = false
    @State private var isRevoking: Bool = false
    @State private var canAddToWallet: Bool = false

    private var isLoadingInProgress: Bool {
        return isPanAndSecurityCodeLoading || isPinLoading || isActivating || isSuspending || isRevoking
    }

    let card: Card

    weak var delegate: CardDetailViewDelegate?

    typealias Detail = DesignSystem.CardDetailDesign
    typealias ButtonStyle = (image: String, title: String, loadingState: Binding<Bool>)

    var body: some View {
        VStack(spacing: 8) {
            if canAddToWallet {
                Button(action: { delegate?.addToWallet() }) {
                    AddToWalletButtonView()
                }
                .frame(width: 200, height: 40)
            }
            contentCard()

            loadingButton(isLoading: $isPinLoading) {
                delegate?.showPinTapped(completion: {
                    $isPinLoading.wrappedValue.toggle()
                })
            } label: {
                HStack {
                    Image(systemName: Constants.pinIcon)
                    Text(Constants.showPinText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .actionButtonStyle()

            stateManagementButtons()

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: Content Card (Core Content)
    @ViewBuilder
    private func contentCard() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            panView()
            securityCodeView()
            expiryDateView()
        }
        .padding(12)
        .background(Color(Detail.backgroundColor))
        .cornerRadius(12)
    }

    @ViewBuilder
    private func panView() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(Constants.panText)
                    .titleStyle()

                if let panView = panAndSecurityCode?.0 {
                    ViewWrapperPresenter(uiView: panView)
                        .frame(height: Constants.infoRowHeight)
                } else {
                    Text(Constants.panPlaceholder)
                        .blurred()
                        .frame(height: Constants.infoRowHeight)
                }
            }

            Spacer()
            loadingButton(isLoading: $isPanAndSecurityCodeLoading) {
                if panAndSecurityCode == nil {
                    delegate?.getPanAndSecurityCodeTapped(completion: {
                        $isPanAndSecurityCodeLoading.wrappedValue = false
                    })
                } else {
                    panAndSecurityCode = nil
                    $isPanAndSecurityCodeLoading.wrappedValue = false
                }
            } label: {
                Image(systemName: panAndSecurityCode == nil ? Constants.showDetailsIcon : Constants.hideDetailsIcon)
            }
        }
    }

    @ViewBuilder
    private func securityCodeView() -> some View {
        VStack(alignment: .leading) {
            Text(Constants.securityCodeText)
                .titleStyle()

            if let securityCodeView = panAndSecurityCode?.1 {
                ViewWrapperPresenter(uiView: securityCodeView)
                    .frame(height: Constants.infoRowHeight)
            } else {
                Text(Constants.securityCodePlaceholder)
                    .blurred()
                    .frame(height: Constants.infoRowHeight)
            }
        }
    }

    @ViewBuilder
    private func expiryDateView() -> some View {
        VStack(alignment: .leading) {
            Text(Constants.expiryDateText)
                .titleStyle()
            Text(card.expiryDateDisplay)
                .font(Font(DesignSystem.Font.title))
                .foregroundColor(Color(Detail.defaultTextColor))
                .frame(height: Constants.infoRowHeight)

        }
    }

    // MARK: Action Buttons (Footer)
    @ViewBuilder
    private func stateManagementButtons() -> some View {
        ForEach(card.possibleStateChanges, id: \.rawValue) {
            buttonChangingState(to: $0)
        }
    }

    private func buttonConfig(for requestedState: CardState) -> ButtonStyle {
        switch requestedState {
        case .active:
            return (Constants.activateIcon, Constants.activateText, $isActivating)
        case .suspended:
            return (Constants.suspendIcon, Constants.suspendText, $isSuspending)
        case .revoked:
            return (Constants.revokeIcon, Constants.revokeText, $isRevoking)

        default:
            return (String(), String(), .constant(false))
        }
    }

    @ViewBuilder
    private func buttonChangingState(to newState: CardState) -> some View {
        let config = buttonConfig(for: newState)

        loadingButton(isLoading: config.loadingState) {
            delegate?.changeCardState(to: newState, completion: {
                config.loadingState.wrappedValue = false

                withAnimation {
                    canAddToWallet = newState == .active
                }
            })
        } label: {
            HStack {
                Image(systemName: config.image)
                Text(config.title)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .actionButtonStyle(isDestructive: newState == .revoked)
    }

    @ViewBuilder
    private func loadingButton(isLoading: Binding<Bool>,
                               action: @escaping () -> Void,
                               @ViewBuilder label: @escaping () -> some View) -> some View {
        Button(action: {
            isLoading.wrappedValue.toggle()
            action()
        }) {
            if isLoading.wrappedValue {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                label()
            }
        }
        .disabled(isLoadingInProgress)
    }

    enum Constants {
        static let panText = "Card Number"
        static let panPlaceholder = "•••• •••• •••• ••••"
        static let securityCodeText = "Security Code"
        static let securityCodePlaceholder = "•••"
        static let expiryDateText = "Expiry Date"
        static let showPinText = "Show PIN"
        static let activateText = "Activate"
        static let suspendText = "Suspend"
        static let revokeText = "Revoke"

        static let pinIcon = "lock"
        static let activateIcon = "bolt"
        static let suspendIcon = "pause"
        static let revokeIcon = "power"
        static let showDetailsIcon = "eye"
        static let hideDetailsIcon = "eye.slash"

        static let buttonHeight: CGFloat = 52
        static let infoRowHeight: CGFloat = 20
    }
}

fileprivate extension View {
    func actionButtonStyle(isDestructive: Bool = false) -> some View {
        modifier(CardDetailView.ActionButton(isDestructive: isDestructive))
    }
}

fileprivate extension Text {
    func titleStyle() -> some View {
        modifier(CardDetailView.Title())
    }

    func blurred() -> some View {
        modifier(CardDetailView.BlurredText())
    }
}
