//
//  ViewWrapperPresenter.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 21/07/2022.
//

import SwiftUI

struct ViewWrapperPresenter: View {
    let uiView: UIView

    var body: some View {
        let viewSize = uiView.systemLayoutSizeFitting(.zero)
        ViewWrapper(wrapped: uiView)
            .frame(width: viewSize.width,
                   height: viewSize.height)
    }
}
