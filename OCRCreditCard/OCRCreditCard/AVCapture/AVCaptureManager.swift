//
//  AVCaptureManager.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import AVFoundation

/*
 AVCaptureManager needs to inherit from NSObject.
 because AVCaptureManager will adopt AVCaptureSession‘s video output delegate.
 */
final class AVCaptureManager: NSObject, ObservableObject {
    enum AVCaptureStatus {
      case unconfigured
      case configured
      case unauthorized
      case failed
    }
    
    
    // AVCaptureSession
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.ocr.sessionqueue")
    // Video Output
    private let videoOutput = AVCaptureVideoDataOutput()
    // Capture Device
    private let device = AVCaptureDevice.default(for: .video)
    
    
    // Status
    private var status: AVCaptureStatus = .unconfigured
    // Current Image Buffer
    @Published var currentImageBuffer: CVImageBuffer?
    // Error
    @Published var error: AVCaptureError?
    
    
    
    
    // Initialize
    override init() {
        super.init()
        configure()
    }
    
    
    // Configure
    private func configure() {
        Task {
            guard await checkCaptureDevicePermission() else { return }
            sessionQueue.async {
                self.configureCaptureSession()
                self.configureSampleBufferDelegate()
                self.session.startRunning()
            }
        }
    }
    
} //: AVCaptureManager


// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension AVCaptureManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        DispatchQueue.main.async {
            guard let buffer = sampleBuffer.imageBuffer else { return }
            self.currentImageBuffer = buffer
        }
    }
    
}


// MARK: Configure

private extension AVCaptureManager {
    
    // MARK: Check Capture Device Permission
    private func checkCaptureDevicePermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch authStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { authorized in
                    if authorized == false {
                        self.setError(.deniedAuthorization)
                    }
                    continuation.resume(returning: authorized)
                }
                
            case .restricted:
                setError(.restrictedAuthorization)
                continuation.resume(returning: false)
                
            case .denied:
                setError(.deniedAuthorization)
                continuation.resume(returning: false)
                
            case .authorized:
                continuation.resume(returning: true)
                
            @unknown
            default:
                setError(.unknownAuthorization)
                continuation.resume(returning: false)
            }
        }
    } //: checkCaptureDevicePermission
    
    
    // MARK: Configure CaptureSession
    // You usually need to configure a capture session just once in your app.
    private func configureCaptureSession() {
        guard status == .unconfigured else { return }
        
        /*
         - So far, this is pretty straightforward.
         - But it’s worth noting that any time you want to change something about an AVCaptureSession configuration,
         - you need to enclose that code between a beginConfiguration and a commitConfiguration.
         */
        session.beginConfiguration()
        do {
            session.commitConfiguration()
        }
        
        // AVCaptureDevice
        guard let device = self.device else {
            setError(.faildToGetCaptureDevice)
            return
        }
        
        // Add Device Input
        do {
            let deviceInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            else {
                setError(.cannotAddDeviceInput)
                return
            }
        }
        catch {
            setError(.createCaptureInput(error))
            return
        }
        
        // Add Video Output
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        else {
            setError(.cannotAddVideoOutput)
            return
        }
        
        // Configured
        status = .configured
    } //: configureCaptureSession
    
    
    // MARK: Configure Sample Buffer Delegate
    func configureSampleBufferDelegate() {
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
    }
    
} //: AVCaptureManager


// MARK: -

private extension AVCaptureManager {
    
    // MARK: Set Error
    func setError(_ error: AVCaptureError) {
        DispatchQueue.main.async {
            self.error = error
            switch error {
            case .deniedAuthorization, .restrictedAuthorization, .unknownAuthorization:
                self.status = .unauthorized
                
            case .createCaptureInput(_), .cannotAddDeviceInput, .cannotAddVideoOutput, .faildToGetCaptureDevice:
                self.status = .failed
            }
        }
    }
    
} //: AVCaptureManager
