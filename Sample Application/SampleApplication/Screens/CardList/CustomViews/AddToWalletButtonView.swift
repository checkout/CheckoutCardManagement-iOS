//
//  AddToWalletButtonView.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 10/02/2023.
//

import SwiftUI
import PassKit

struct AddToWalletButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKAddPassButton {
        PKAddPassButton()
    }
    
    func updateUIView(_ uiView: PKAddPassButton, context: Context) {}
}
