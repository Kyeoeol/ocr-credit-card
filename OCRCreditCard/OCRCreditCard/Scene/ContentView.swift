//
//  ContentView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/04/29.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Properties
    
    @ObservedObject private var ocrManager = OCRManager()
    
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            // CaptureFrame
            CaptureFrameView(frame: ocrManager.frame)
            // OCRError
            OCRErrorView(error: ocrManager.error)
        }
    }
}


// MARK: Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
