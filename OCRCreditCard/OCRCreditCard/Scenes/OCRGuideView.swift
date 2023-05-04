//
//  OCRGuideView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import SwiftUI

struct OCRGuideView: View {
    
    // MARK: Properties
    
    @Environment(\.ocrGuideSize) private var ocrGuideSize
    
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
                .opacity(0.6)
            
            Rectangle()
                .frame(width: CGFloat(ocrGuideSize.width),
                       height: CGFloat(ocrGuideSize.height))
                .cornerRadius(12)
                .blendMode(.destinationOut)
        } //: ZStack
        .compositingGroup()
    }
}


// MARK: Previews

struct OCRGuideView_Previews: PreviewProvider {
    static var previews: some View {
        OCRGuideView()
            .environment(
                \.windowSize,
                 CGSize(width: 375, height: 500)
            )
    }
}
