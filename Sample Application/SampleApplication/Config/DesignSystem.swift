// 
//  DesignSystem.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 29/03/2023.
//

import UIKit

enum DesignSystem {

    enum AuthenticationScreenDesign {
        static let buttonBackgroundColor = UIColor(hexString: "#EDF5FF")
        static let buttonTextColor = UIColor(hexString: "#2E6CF6")
    }

    enum CardManagement {
        static let defaultSettings: DesignableText = .init(font: .systemFont(ofSize: 15),
                                                           textColor: Color.darkText)
        static let pan: DesignableText = defaultSettings
        static let securityCode: DesignableText = defaultSettings
        static let pin: DesignableText = .init(font: .systemFont(ofSize: 24),
                                               textColor: Color.darkText)

        static let panTextSeparator = " "
    }

    enum CardDesign {
        static let gradientColors: [UIColor] = [.init(hexString: "#22255C"),
                                                .init(hexString: "#0C1142")]
        static let cornerRadius: CGFloat = 18
        static let border: BorderStyle = .init(color: UIColor(hexString: "#FFFFFF"), width: 2)
        static let companyLogoName = "CompanyLogo"
        static let cardIssuerLogoName = "MastercardLogo"
    }

    enum CardDetailDesign {
        static let backgroundColor: UIColor = .init(hexString: "#F8F4F4")
        static let titleFontColor = Color.lightText
        static let defaultTextColor = Color.darkText
        static let destructiveColor = UIColor(hexString: "#AD283E")
    }

    enum Color {
        static let darkText = UIColor(hexString: "#272932")
        static let lightText = UIColor(hexString: "#727272")
    }

    enum Font {
        static let boldSubtitle = UIFont.boldSystemFont(ofSize: 17)
        static let boldTitle = UIFont.boldSystemFont(ofSize: 28)

        static let title = UIFont.systemFont(ofSize: 15)
        static let subtitle = UIFont.systemFont(ofSize: 13)
        static let body = UIFont.systemFont(ofSize: 11)
        
        static let buttonText = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }
}
