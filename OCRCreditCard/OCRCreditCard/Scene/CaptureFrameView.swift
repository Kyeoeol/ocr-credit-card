//
//  CaptureFrameView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import SwiftUI

struct CaptureFrameView: View {
    
    // MARK: Properties
    
    var frame: CGImage?
    private let frameLabel = Text("Capture Frame")
    
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            if let frame {
                GeometryReader { proxy in
                    Image(frame,
                          scale: 1.0,
                          orientation: .right,
                          label: frameLabel)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width,
                           height: proxy.size.height)
                    .clipped()
                }
            }
            else {
                Color.black
            }
        } //: ZStack
        .edgesIgnoringSafeArea(.all)
    }
}


// MARK: Previews

struct CaptureFrameView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureFrameView(frame: nil)
    }
}
