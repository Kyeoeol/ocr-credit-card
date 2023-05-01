//
//  AVCaptureManager.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import AVFoundation

final class AVCaptureManager: ObservableObject {
    enum AVCaptureStatus {
      case unconfigured
      case configured
      case unauthorized
      case failed
    }
    
    
    // Status
    private var status: AVCaptureStatus = .unconfigured
    
    // AVCaptureSession
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.ocr.sessionqueue")
    // Video Output
    private let videoOutput = AVCaptureVideoDataOutput()
    // Discovery Session
    private let discoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [
            .builtInTrueDepthCamera,
            .builtInDualCamera,
            .builtInWideAngleCamera
        ],
        mediaType: .video,
        position: .unspecified
    )
    
    // Error
    @Published var error: AVCaptureError?
    
    
    
    
    // Initialize
    private init() {
      configure()
    }
    
    
    // Configure
    private func configure() {
        Task {
            guard await checkCaptureDevicePermission() else { return }
            sessionQueue.async {
                self.configureCaptureSession()
                self.session.startRunning()
            }
        }
    }
    
    
    
    
    // Set Sample Buffer Delegate
    func set(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
             queue: DispatchQueue) {
        sessionQueue.async {
            self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
        }
    }
    
} //: AVCaptureManager


// MARK: Configure

private extension AVCaptureManager {
    
    // Check Capture Device Permission
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
    
    
    // Configure CaptureSession
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
        let device = self.getAVCaptureDevice(in: .back)
        guard let device = device else {
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
    
} //: AVCaptureManager



// MARK: -

private extension AVCaptureManager {
    
    // Get AVCaptureDevice
    func getAVCaptureDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice? {
      let devices = self.discoverySession.devices
      let device = devices.first { $0.position == position }
      return device
    }
    
    
    // Set Error
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
