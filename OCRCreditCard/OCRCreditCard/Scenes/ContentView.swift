//
//  ContentView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/04/29.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Properties
    
//    @State private var ocrCaptureResult: OCRCaptureResult?
    @ObservedObject var avCaptureService = AVCaptureService.shared
    
    private var image: CGImage? {
        return avCaptureService.bufferImage
    }
    
    // MARK: Body
    
    var body: some View {
        ZStack {
//            OCRCaptureView(ocrCaptureResult: $ocrCaptureResult)
//            OCRGuideView()
//            OCRCaptureResultView(ocrCaptureResult: $ocrCaptureResult)
//            Color.black
            
            
            // TEST
            if let image {
                GeometryReader { proxy in
                    Image(image,
                        scale: 1.0,
                        label: Text("TEST"))
                  .resizable()
                  .scaledToFill()
                  .frame(width: proxy.size.width,
                         height: proxy.size.height,
                         alignment: .center)
                  .clipped()
                } //: GeometryReader
            }
            
            
            
            OCRCaptureErrorView(error: avCaptureService.error)
        }
    }
}


// MARK: Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
