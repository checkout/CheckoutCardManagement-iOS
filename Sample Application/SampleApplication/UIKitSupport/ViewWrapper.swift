//
//  ViewWrapper.swift
//  SampleApplication
//
//  Created by Alex Ioja-Yang on 02/11/2022.
//
import SwiftUI

struct ViewWrapper: UIViewRepresentable {
    let wrapped: UIView

    func makeUIView(context: Context) -> UIView {
        wrapped
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
