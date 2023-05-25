//
//  SampleApplicationApp.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 15/03/2023.
//

import SwiftUI

#if canImport(CheckoutCardManagement)
import CheckoutCardManagement
#elseif canImport(CheckoutCardManagementStub)
import CheckoutCardManagementStub
#endif

@main
struct SampleApplicationApp: App {
    var body: some Scene {
        WindowGroup {
            let cardManager = CheckoutCardManager(demoEnvironment: .sandbox)
            CardListView(viewModel: CardListViewModel(cardManager: cardManager))
        }
    }
}
