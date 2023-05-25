// 
//  CardView.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 18/04/2023.
//

import SwiftUI

#if canImport(CheckoutCardManagement)
import CheckoutCardManagement
#elseif canImport(CheckoutCardManagementStub)
import CheckoutCardManagementStub
#endif

struct CardView: View {
    @Binding var card: Card

    private let design = DesignSystem.CardDesign.self

    var body: some View {
        VStack {
            ZStack {
                background()
                cardContent()
                    .padding(24)
            }
        }
    }

    @ViewBuilder
    private func background() -> some View {
        RoundedRectangle(cornerRadius: design.cornerRadius)
            .fill(LinearGradient(colors: design.gradientColors.map(Color.init),
                                 startPoint: .top,
                                 endPoint: .bottom))
            .overlay {
                RoundedRectangle(cornerRadius: design.cornerRadius)
                    .stroke(Color(design.border.color), lineWidth: design.border.width)
            }
    }

    @ViewBuilder
    private func cardContent() -> some View {
        VStack {
            GeometryReader { geometry in
                HStack(spacing: geometry.size.width / 3) {
                    Image(design.companyLogoName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Text(card.last4DigitsDisplay)
                        .font(.system(size: 11))
                        .foregroundColor(.init(white: 1, opacity: 0.5))
                }
            }
            Spacer()
            HStack {
                Text(card.stateDisplay)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                Spacer()
                Image(design.cardIssuerLogoName)
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}
