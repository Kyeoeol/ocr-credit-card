//
//  OCRFrameView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/06.
//

import SwiftUI

struct OCRFrameView: View {
    
    // MARK: Properties
    
    @Binding var image: CGImage?
    
    private let label = Text("OCRFrameView")
    
    
    // MARK: Body
    
    var body: some View {
        if let image {
            GeometryReader { proxy in
                Image(
                    image,
                    scale: 1.0,
                    label: label
                )
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width,
                       height: proxy.size.height)
                .clipped()
            } //: GeometryReader
        }
        else {
            Color.black
        }
    }
}


// MARK: Previews

struct OCRFrameView_Previews: PreviewProvider {
    static var previews: some View {
        OCRFrameView(image: .constant(nil))
    }
}
