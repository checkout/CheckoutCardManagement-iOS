// 
//  CardDetailView+ViewModifiers.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 02/05/2023.
//

import SwiftUI

extension CardDetailView {
    struct ActionButton: ViewModifier {
        let isDestructive: Bool

        func body(content: Content) -> some View {
            content
                .frame(maxWidth: .infinity,
                       minHeight: Constants.buttonHeight,
                       maxHeight: Constants.buttonHeight)
                .background(Color(Detail.backgroundColor))
                .foregroundColor(isDestructive ? Color(Detail.destructiveColor) : Color(Detail.defaultTextColor))
                .cornerRadius(12)
                .font(Font(DesignSystem.Font.buttonText))
        }
    }

    struct Title: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: 13))
                .foregroundColor(Color(Detail.titleFontColor))
        }
    }

    struct BlurredText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(.white)
                .overlay {
                    Color.secondary.blur(radius: 8)
                }
        }
    }
}
