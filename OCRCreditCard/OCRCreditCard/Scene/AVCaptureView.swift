//
//  AVCaptureView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/02.
//

import AVFoundation
import SwiftUI

enum AVCaptureStatus {
  case unconfigured
  case configured
  case unauthorized
  case authorized
  case failed
}
struct AVCaptureView: View {
    
    // MARK: Properties
    
    @State private var error: AVCaptureError?
    @State private var status: AVCaptureStatus = .unconfigured
    
    // AVCaptureSession
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.ocr.sessionqueue")
    // Video Output
    private let videoOutput = AVCaptureVideoDataOutput()
    // Capture Device
    private let device = AVCaptureDevice.default(for: .video)
    
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            if let error {
                AVCaptureErrorView(error: error)
            }
            else if status == .authorized {
                AVCaptureViewRepresentable(
                    error: $error,
                    status: $status,
                    session: session,
                    sessionQueue: sessionQueue,
                    videoOutput: videoOutput,
                    device: device
                )
                .edgesIgnoringSafeArea(.all)
            }
            else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            Task {
                await checkCaptureDevicePermission()
            }
        }
    }
}


// MARK: Functions

private extension AVCaptureView {
    
    // MARK: Check Capture Device Permission
    func checkCaptureDevicePermission() async {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined:
            let authorized = await AVCaptureDevice.requestAccess(for: .video)
            if authorized {
                status = .authorized
            }
            else {
                setError(.deniedAuthorization)
            }

        case .restricted:
            setError(.restrictedAuthorization)

        case .denied:
            setError(.deniedAuthorization)

        case .authorized:
            status = .authorized

        @unknown
        default:
            setError(.unknownAuthorization)
        }
    }
    
    
    // MARK: Set Error
    func setError(_ error: AVCaptureError) {
        self.error = error
        switch error {
        case .deniedAuthorization, .restrictedAuthorization, .unknownAuthorization:
            self.status = .unauthorized
            
        case .createCaptureInput(_), .cannotAddDeviceInput, .cannotAddVideoOutput, .faildToGetCaptureDevice:
            self.status = .failed
        }
    }
    
}


// MARK: Previews

struct AVCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        AVCaptureView()
    }
}
