//
//  AVCaptureService.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/04.
//

import AVFoundation
import SwiftUI
import Combine

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
    @Published var error: Error?
    
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
    
    // Cancellable
    private var cancellable = Set<AnyCancellable>()
    
    
    
    
    // MARK: Initialize
    
    private init() {
        Task {
            await configure()
        }
        
    }
    
    
    // Subscriptions
    
    private func subscriptions() {
        $error
            .compactMap { $0 as? AVCaptureError }
            .sink { error in
                self.setStatus(with: error)
            }
            .store(in: &cancellable)
    }
    
    
    
    
    // MARK: Start Session
    
    func startSession() {
        guard session.isRunning == false else { return }
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    
    // MARK: Stop Session
    
    func stopSession() {
        guard session.isRunning else { return }
        session.stopRunning()
    }
    
}


// MARK: - Configure

private extension AVCaptureService {
    
    private func configure() async {
        do {
            try await checkCaptureDevicePermission()
        }
        catch {
            setError(error)
        }
    }
    
    
    // MARK: Check Permission
    
    func checkCaptureDevicePermission() async throws {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined:
            let authorized = await AVCaptureDevice.requestAccess(for: .video)
            if authorized == false {
                throw AVCaptureError.deniedAuthorization
            }
            
        case .restricted:
            throw AVCaptureError.restrictedAuthorization

        case .denied:
            throw AVCaptureError.deniedAuthorization

        case .authorized:
            break

        @unknown
        default:
            throw AVCaptureError.unknownAuthorization
        }
    }
    
    
    // MARK: Set Capture Session
    
    func setCaptureSession() {
        session.sessionPreset = .photo
    }
    
    
    // MARK: Set Device Input
    
    func setDeviceInput() {
        
    }
    
    
    // MARK: Set VideoData Output
    
    func setVideoDataOutput() {
        
    }
    
}


// MARK: -

private extension AVCaptureService {
    
    // MARK: Set Error
    
    func setError(_ error: Error) {
        DispatchQueue.main.async {
            if let error = error as? AVCaptureError {
                self.error = error
            } else {
                self.error = AVCaptureError.unspecified("ERROR::Failed to configure AVCaptureService.")
            }
        }
    }
    
    
    // MARK: Set Status
    
    func setStatus(with error: AVCaptureError) {
        switch error {
        case .faildToGetCaptureDevice:
            status = .failed
            
        case .cannotAddDeviceInput:
            status = .failed
            
        case .cannotAddVideoOutput:
            status = .failed
            
        case .createCaptureInput:
            status = .failed
            
        case .deniedAuthorization:
            status = .unauthorized
            
        case .restrictedAuthorization:
            status = .unauthorized
            
        case .unknownAuthorization:
            status = .unauthorized
            
        case .unspecified:
            status = .failed
        }
    }
    
}
