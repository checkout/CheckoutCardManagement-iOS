//
//  ErrorView.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 20/07/2022.
//

import SwiftUI

struct ErrorView: View {

    let text: String

    var body: some View {
        ZStack {
            Color.orange
                .cornerRadius(20)
                .layoutPriority(-1)
            Text(text)
                .font(Font(DesignSystem.Font.boldSubtitle))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 24, leading: 32, bottom: 24, trailing: 32))
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(text: "Hello World!")
            .previewLayout(.fixed(width: 300, height: 100))
    }
}
