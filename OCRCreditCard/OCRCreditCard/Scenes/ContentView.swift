//
//  ContentView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/04/29.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Properties
    
    @State private var ocrCaptureResult: OCRCaptureResult?
    
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            OCRCaptureView(ocrCaptureResult: $ocrCaptureResult)
            OCRGuideView()
            OCRCaptureResultView(ocrCaptureResult: $ocrCaptureResult)
        }
    }
}


// MARK: Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
