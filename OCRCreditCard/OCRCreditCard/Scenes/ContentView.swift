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
    
    
    // MARK: Body
    
    var body: some View {
        ZStack {
//            OCRCaptureView(ocrCaptureResult: $ocrCaptureResult)
//            OCRGuideView()
//            OCRCaptureResultView(ocrCaptureResult: $ocrCaptureResult)
//            Color.black
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
