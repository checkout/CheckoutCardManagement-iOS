// 
//  SpinningCircleView.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 22/03/2023.
//

import SwiftUI

struct SpinningCircleView: View {
    @Binding var isAnimating: Bool

    var body: some View {
        Circle()
            .stroke(style: StrokeStyle(lineWidth: Constants.Size.lineWidth, dash: [Constants.Size.dashLength]))
            .frame(width: Constants.Size.dimension, height: Constants.Size.dimension)
            .rotationEffect(Angle(degrees: isAnimating ? Constants.Animation.rotation : Constants.Animation.noRotation))
            .animation(isAnimating ? Animation.linear(duration: Constants.Animation.duration).repeatForever(autoreverses: false) : nil, value: isAnimating)
    }
}

extension SpinningCircleView {
    enum Constants {
        enum Animation {
            static let duration: CGFloat = 3
            static let rotation: CGFloat = 360
            static let noRotation: CGFloat = 0
        }

        enum Size {
            static let dimension: CGFloat = 100
            static let lineWidth: CGFloat = 2
            static let dashLength: CGFloat = 12
        }
    }
}

struct SpinningCircleView_Previews: PreviewProvider {
    static var previews: some View {
        SpinningCircleView(isAnimating: .constant(true))
    }
}
