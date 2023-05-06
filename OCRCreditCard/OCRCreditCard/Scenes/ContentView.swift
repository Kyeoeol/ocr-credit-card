//
//  ContentView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/04/29.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    // MARK: Properties
    
    @Environment(\.windowSize) var windowSize
    @Environment(\.ocrGuideSize) var ocrGuideSize
    
    @ObservedObject var ocrManager = OCRManager()
    @State private var isShowAlert = false
    
    private var resultData: OCRResultData? {
        return ocrManager.resultData
    }
    
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            // Frame
            OCRFrameView(image: $ocrManager.frameImage)
                .edgesIgnoringSafeArea(.all)
            // Guide
            OCRGuideView()
            // Error
            OCRErrorView(error: $ocrManager.error)
        } //: ZStack
        .onAppear {
            ocrManager.setGuideSize(
                windowSize: windowSize,
                guideSize: ocrGuideSize
            )
        }
        .onReceive(Just(resultData)) { resultData in
            guard resultData != nil else { return }
            ocrManager.stopOCR()
            isShowAlert = true
        }
        .alert(isPresented: $isShowAlert) {
            Alert(
                title: Text("OCR Result"),
                message: Text("""
                CardNumber:
                \(resultData?.cardNumber ?? "")
                ValidDate:
                \(resultData?.cardValidDate ?? "")
                """),
                dismissButton: .default(
                    Text("확인"),
                    action: {
                        ocrManager.startOCR()
                    }
                )
            )
        } //: Alert
    }
}


// MARK: Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
