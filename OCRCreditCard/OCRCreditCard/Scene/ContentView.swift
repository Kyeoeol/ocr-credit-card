//
//  ContentView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/04/29.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Properties
    
    @ObservedObject private var captureManager = AVCaptureManager()
    
    
    // MARK: Body
    
    var body: some View {
        CaptureFrameView(frame: nil)
    }
}


// MARK: Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
