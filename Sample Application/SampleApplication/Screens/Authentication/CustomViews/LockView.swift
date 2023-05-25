// 
//  LockView.swift
//  SampleApplication
//
//  Created by Okhan Okbay on 22/03/2023.
//

import SwiftUI

struct LockView: View {
    @Binding var isUnlocked: Bool

    private let animationsCompleted: (() -> Void)?

    init(isUnlocked: Binding<Bool>, animationsCompleted: (() -> Void)? = nil) {
        self._isUnlocked = isUnlocked
        self.animationsCompleted = animationsCompleted
    }

    var body: some View {
        ZStack {
            Image(systemName: isUnlocked ? Constants.Image.unlocked : Constants.Image.locked)
                .font(.system(size: Constants.Font.size))
                .foregroundColor(isUnlocked ? .green : .red)
                .transition(.opacity)
                .rotation3DEffect(.degrees(isUnlocked ? Constants.Animation.unlockedRotation : Constants.Animation.lockedRotation),
                                  axis: (x: Constants.Animation.axis, y: Constants.Animation.axis, z: Constants.Animation.axis))
                .animation(isUnlocked ? Animation.linear(duration: Constants.Animation.duration) : nil, value: isUnlocked)
                .task {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.duration + 1) {
                        animationsCompleted?()
                    }
                }
        }
    }
}

extension LockView {
    enum Constants {
        enum Image {
            static let locked = "lock.fill"
            static let unlocked = "lock.open.fill"
        }

        enum Animation {
            static let duration: CGFloat = 0.3
            static let lockedRotation: CGFloat = 0
            static let unlockedRotation: CGFloat = 360
            static let axis: CGFloat = 1
        }

        enum Font {
            static let size: CGFloat = 35
        }
    }
}

struct LockView_Previews: PreviewProvider {
    static var previews: some View {
        LockView(isUnlocked: .constant(true), animationsCompleted: {
            print("Animations are completed")
        })
    }
}
