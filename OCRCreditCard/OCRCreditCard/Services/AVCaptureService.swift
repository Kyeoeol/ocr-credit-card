//
//  AVCaptureService.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/04.
//

import AVFoundation
import SwiftUI

final class AVCaptureService: ObservableObject {
    enum Status {
      case unconfigured
      case configured
      case unauthorized
      case failed
    }
    
    static let shared = AVCaptureService()
    
    
    // MARK: Properties
    
    // Output
    @Published var error: AVCaptureError?
    
    var serviceStatus: AVCaptureService.Status {
        self.status
    }
    
    
    // Session
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.ocr.sessionqueue")
    // Video Output
    private let videoOutput = AVCaptureVideoDataOutput()
    // Capture Device
    private let device = AVCaptureDevice.default(for: .video)
    
    // Status
    private var status: Status = .unconfigured
    
    
    
    // MARK: Initialize
    
    private init() {
        configure()
    }
    
}


// MARK: -

private extension AVCaptureService {
    
    // MARK: Configure
    
    private func configure() {
        Task {
            guard await checkCaptureDevicePermission() else { return }
        }
    }
    
    
    // Check Permission
    func checkCaptureDevicePermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch authStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { authorized in
                    if authorized {
                        self.status = .unauthorized
                        self.error = .deniedAuthorization
                        continuation.resume(returning: false)
                    }
                    else {
                        continuation.resume(returning: true)
                    }
                }

            case .restricted:
                status = .unauthorized
                error = .restrictedAuthorization
                continuation.resume(returning: false)

            case .denied:
                status = .unauthorized
                error = .deniedAuthorization
                continuation.resume(returning: false)

            case .authorized:
                continuation.resume(returning: true)

            @unknown
            default:
                status = .unauthorized
                error = .unknownAuthorization
                continuation.resume(returning: false)
            }
            
        }
    }
    
}
