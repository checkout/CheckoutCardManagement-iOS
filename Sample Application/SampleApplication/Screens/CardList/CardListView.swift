//
//  CardListView.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 15/03/2023.
//

import SwiftUI

struct CardListView: View {

    private enum Constants {
        static let cardListAnimationDuration: CGFloat = 0.5
        static let cardDetailAnimationStart: CGFloat = 0.4
        static let cardDetailAnimationDuration: CGFloat = 0.2
    }

    @State private var showCardDetails: Bool = false
    @ObservedObject private var viewModel: CardListViewModel

    init(viewModel: CardListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea(edges: [.leading, .trailing, .bottom])
            contentView()
        }
        .onChange(of: viewModel.showAuthentication, perform: { _ in
            viewModel.authenticationUpdate()
        })
        .sheet(isPresented: $viewModel.showAuthentication) {
            AuthenticationView(viewModel: AuthenticationViewModel())
                .environmentObject(viewModel.authenticationRecord)
                .presentationDetents([.height(400)])
        }
        .sheet(isPresented: $viewModel.showPinSheet, content: {
            if let pin = viewModel.pin {
                VStack(alignment: .center) {
                    Text("PIN")
                        .foregroundColor(Color(DesignSystem.Color.lightText))
                    ViewWrapperPresenter(uiView: pin)
                }
                .presentationDetents([.fraction(0.2)])
            }
        })
        .confirmationDialog("Destructive Action Warning",
                            isPresented: $viewModel.showDestructiveActionDialog,
                            actions: destructiveActionDialogueActions) {
            Text("The action you are about to take is irreversible. Are you sure you want to continue?")
        }
    }
}

// MARK: View Builders
extension CardListView {
    @ViewBuilder
    private func contentView() -> some View {
        ZStack {
            if !viewModel.cards.isEmpty {
                GeometryReader { geometry in
                    ZStack {
                        cardList(geometry: geometry)
                        if showCardDetails {
                            cardDetailView(geometry: geometry)
                        }
                    }
                }
            }

            if viewModel.isLoading {
                progressView()
            }

            if let message = viewModel.errorMessage {
                errorView(message: message)
            }
        }
    }

    @ViewBuilder
    private func cardDetailView(geometry: GeometryProxy) -> some View {
        if let selectedCard = viewModel.selectedCard {
            VStack {
                let topSpacing = (CardListViewModel.LayoutConstants.standardCardHeight * CardListViewModel.LayoutConstants.selectedScaledPercentage)

                Spacer()
                    .frame(height: topSpacing)
                CardDetailView(panAndSecurityCode: $viewModel.panAndSecurityCode,
                               card: selectedCard,
                               delegate: viewModel)
                Spacer()
            }
        }
    }

    @ViewBuilder
    private func cardList(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(alignment: .center, spacing: viewModel.cardListStackSpace) {
                ForEach($viewModel.cards, id: \.id) { card in

                    let isCardSelected = viewModel.selectedCardID == card.id
                    let scaleFactor = isCardSelected ? CardListViewModel.LayoutConstants.selectedScaledPercentage : 1
                    let height = CardListViewModel.LayoutConstants.standardCardHeight
                    let expectedHeight = isCardSelected ? height * scaleFactor : height
                    let expectedWidth = isCardSelected ?
                    expectedHeight * CardListViewModel.LayoutConstants.cardAspectRatio : nil

                    CardView(card: card)
                        .onTapGesture {
                            viewModel.cardSelected(card.wrappedValue)

                            if showCardDetails {
                                showCardDetails = false
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.cardDetailAnimationStart) {
                                    withAnimation(.easeIn(duration: Constants.cardDetailAnimationDuration)) {
                                        showCardDetails.toggle()
                                    }
                                }
                            }
                        }
                        .frame(width: expectedWidth, height: expectedHeight)
                        .offset(y: viewModel.offsetY(for: card.wrappedValue,
                                                     in: geometry.size,
                                                     topSafeAreaInsets: geometry.safeAreaInsets.top))
                        .scaleEffect(x: scaleFactor, y: scaleFactor)
                        .animation(.spring(response: Constants.cardListAnimationDuration), value: viewModel.selectedCardID)
                }
            }
        }
        .scrollDisabled(viewModel.selectedCardID != nil)
        .padding(.horizontal, CardListViewModel.LayoutConstants.cardListPadding)
    }

    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack {
            Spacer()
                .frame(idealHeight: .infinity)
            ErrorView(text: message)
            Spacer()
                .frame(height: 8)
        }
        .onTapGesture {
            viewModel.errorMessageTapped()
        }
    }

    @ViewBuilder
    private func progressView() -> some View {
        ZStack {
            ProgressView()
                .tint(Color.primary)
                .foregroundColor(.clear)
        }
        .edgesIgnoringSafeArea(.all)
    }

    @ViewBuilder
    private func destructiveActionDialogueActions() -> some View {
        VStack {
            Button(role: .destructive) {
                viewModel.revokeCard()
            } label: {
                Text("Proceed")
            }
            Button(role: .cancel) {
                viewModel.revokeCancelled()
            } label: {
                Text("Cancel")
            }
        }
    }
}
