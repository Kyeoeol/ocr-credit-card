//
//  AVCaptureViewRepresentable.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/02.
//

import AVFoundation
import SwiftUI

struct AVCaptureViewRepresentable: UIViewRepresentable {
    


    // MARK: Properties
    
    @Binding var error: AVCaptureError?
    @Binding var status: AVCaptureStatus

    // AVCaptureSession
    var session: AVCaptureSession
    var sessionQueue: DispatchQueue
    // Video Output
    var videoOutput: AVCaptureVideoDataOutput
    // Capture Device
    var device: AVCaptureDevice?
    
    
  
    
    
    // MARK: makeUIView
    
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    
    
    
    // MARK: updateUIView
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // ...
    }
}


// MARK: Configures

private extension AVCaptureViewRepresentable {
    
    // MARK: Check Capture Device Permission
    
    
}


// MARK: -

private extension AVCaptureViewRepresentable {
    
    // MARK: Set Error
//    func setError(_ error: AVCaptureError) {
//        DispatchQueue.main.async {
//            self.error = error
//            switch error {
//            case .deniedAuthorization, .restrictedAuthorization, .unknownAuthorization:
//                self.status = .unauthorized
//
//            case .createCaptureInput(_), .cannotAddDeviceInput, .cannotAddVideoOutput, .faildToGetCaptureDevice:
//                self.status = .failed
//            }
//        }
//    }
    
}
