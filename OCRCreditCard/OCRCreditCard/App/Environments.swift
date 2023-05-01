//
//  Environments.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import SwiftUI

// WindowSizeKey
private struct WindowSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var windowSize: CGSize {
        get { self[WindowSizeKey.self] }
        set { self[WindowSizeKey.self] = newValue }
    }
}


// OCRGuideSizeKey
private struct OCRGuideSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var ocrGuideSize: CGSize {
        get {
            let windowSize = self[WindowSizeKey.self]
            let horizontalPadding: CGFloat = 64
            /// (국제표준)신용카드사이즈 = 85.6mm * 53.98mm
            let creditCardStandardRate = CGFloat(53.98) / CGFloat(85.6)
            let width = max(windowSize.width - horizontalPadding, 0)
            let height = width * creditCardStandardRate
            return CGSize(width: width, height: height)
        }
    }
}
