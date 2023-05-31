//
//  CardListViewModel+LayoutCalculations.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 28/04/2023.
//

import UIKit

#if canImport(CheckoutCardManagement)
import CheckoutCardManagement
#elseif canImport(CheckoutCardManagementStub)
import CheckoutCardManagementStub
#endif

// Extension to ViewModel handling UI layout properties
extension CardListViewModel {

    enum LayoutConstants {
        static let standardCardHeight: CGFloat = (UIScreen.main.bounds.size.width - cardListPadding * 2) / cardAspectRatio
        static let cardAspectRatio: CGFloat = 1.586
        static let cardListPadding: CGFloat = 12
        static let collapsedCardsVisibleSpace: CGFloat = 15
        static let selectedScaledPercentage: CGFloat = 0.75
    }

    func offsetY(for card: Card, in frameSize: CGSize, topSafeAreaInsets: CGFloat) -> CGFloat {
        let index = cards.firstIndex(where: { $0.id == card.id }) ?? 1
        guard selectedCardID != nil else {
            return 0
        }
        guard card.id != selectedCard?.id else {
            return 0
        }
        return frameSize.height + CGFloat(index) * LayoutConstants.collapsedCardsVisibleSpace
    }

    static func cardOverlappingOffset(hasSelectedCard: Bool) -> CGFloat {
        LayoutConstants.standardCardHeight * -1 * (hasSelectedCard ? 0.95 : 0.7)
    }
}
