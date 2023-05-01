//
//  OCRGuideView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import SwiftUI

struct OCRGuideView: View {
    
    // MARK: Properties
    
    @Environment(\.ocrGuideSize) var ocrGuideSize
    
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
                .opacity(0.6)
            
            Rectangle()
                .frame(width: ocrGuideSize.width,
                       height: ocrGuideSize.height)
                .blendMode(.destinationOut)
        } //: ZStack
        .compositingGroup()
    }
}


// MARK: Previews

struct OCRGuideView_Previews: PreviewProvider {
    static var previews: some View {
        OCRGuideView()
    }
}
