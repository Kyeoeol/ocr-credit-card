//
//  ContentView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/04/29.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Properties
    
    @ObservedObject var avCaptureManeger = AVCaptureManager()
    
    private var buffer: CVImageBuffer? {
        return avCaptureManeger.currentImageBuffer
    }
    private var frame: CGImage? {
        return buffer?.createCGImage()
    }
    private var error: Error? { return avCaptureManeger.error }
    
    
    // MARK: Body
    
    var body: some View {
//        ZStack {
//            // CaptureFrame
//            CaptureFrameView(frame: frame)
//
//            // OCR: Guide
//            OCRGuideView()
//
//            // OCR: Result
//            OCRResultView(buffer: buffer)
//
//            // Capture Error
//            CaptureErrorView(error: error)
//        }
        AVCaptureView()
    }
}


// MARK: Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
