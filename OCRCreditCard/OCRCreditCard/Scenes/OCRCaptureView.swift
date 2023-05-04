//
//  OCRCaptureView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/02.
//

import AVFoundation
import SwiftUI
import Combine

struct OCRCaptureView: View {
    enum OCRAuthStatus {
      case unauthorized
      case authorized
    }
    
    // MARK: Properties
    
    @Binding var ocrCaptureResult: OCRCaptureResult?
    
    @State private var error: AVCaptureError?
    @State private var status: OCRAuthStatus = .unauthorized
    @State private var cardNumber: String?
    @State private var cardValidDate: String?
    
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
                OCRCaptureErrorView(error: error)
            }
            else if status == .authorized {
                GeometryReader { proxy in
                    OCRCaptureViewRepresentable(
                        error: $error,
                        cardNumber: $cardNumber,
                        cardValidDate: $cardValidDate,
                        session: session,
                        sessionQueue: sessionQueue,
                        videoOutput: videoOutput,
                        device: device,
                        previewLayerSize: CGSize(width: proxy.size.width,
                                                 height: proxy.size.height)
                    )
                }
            }
            else {
                Color.black
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            Task {
                await checkCaptureDevicePermission()
            }
        }
        .onReceive(
            Just(cardNumber).zip(Just(cardValidDate))
        ) { cardNumber, cardValidDate in
            guard let cardNumber, let cardValidDate else { return }
            session.stopRunning()
            ocrCaptureResult = OCRCaptureResult(
                cardNumber: cardNumber,
                cardValidDate: cardValidDate
            )
        }
    }
} //: OCRCaptureView


// MARK: Functions

private extension OCRCaptureView {
    
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
                error = .deniedAuthorization
                status = .unauthorized
            }

        case .restricted:
            error = .restrictedAuthorization
            status = .unauthorized

        case .denied:
            error = .deniedAuthorization
            status = .unauthorized

        case .authorized:
            status = .authorized

        @unknown
        default:
            error = .unknownAuthorization
            status = .unauthorized
        }
    }
    
}


// MARK: Previews

struct OCRCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        OCRCaptureView(ocrCaptureResult: .constant(nil))
    }
}
