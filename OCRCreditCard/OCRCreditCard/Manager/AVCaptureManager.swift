//
//  AVCaptureManager.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/04.
//

import AVFoundation
import SwiftUI
import Combine

/*
 Needs to inherit from NSObject.
 Because AVCaptureService will adopt AVCaptureSession‘s video output.
 */
final class AVCaptureManager: NSObject, ObservableObject {
    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }
    
    static let shared = AVCaptureManager()
    
    
    // MARK: Properties
    
    // Output
    @Published var error: Error?
    @Published var currentBuffer: CVImageBuffer?
    
    var serviceStatus: AVCaptureManager.Status {
        self.status
    }
    
    
    // Session
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.ocr.sessionQueue")
    // Video Output
    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoOutputQueue = DispatchQueue(
      label: "com.ocr.videoOutputQueue",
      qos: .userInteractive,
      attributes: [],
      autoreleaseFrequency: .workItem
    )
    // Capture Device
    private let device = AVCaptureDevice.default(for: .video)
    
    // Status
    private var status: Status = .unconfigured
    
    // Cancellable
    private var cancellable = Set<AnyCancellable>()
    
    
    
    
    // MARK: Initialize
    
    private override init() {
        super.init()
        
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


// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension AVCaptureManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let buffer = sampleBuffer.imageBuffer else {
            return
        }
        DispatchQueue.main.async {
            self.currentBuffer = buffer
        }
    }
    
}


// MARK: - Configure

private extension AVCaptureManager {
    
    private func configure() async {
        do {
            try await checkCaptureDevicePermission()
            try await setCaptureSession()
            try await setDeviceInput()
            try await setVideoDataOutput()
            startSession()
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
    
    func setCaptureSession() async throws {
        guard status == .unconfigured else {
            throw AVCaptureError.unspecified("ERROR::Capture session is already configured.")
        }
        /*
         So far, this is pretty straightforward.
         But it’s worth noting that any time you want to change something about an AVCaptureSession configuration,
         you need to enclose that code between a beginConfiguration and a commitConfiguration.
         */
        session.beginConfiguration()
        session.sessionPreset = .photo
        do {
          self.session.commitConfiguration()
        }
    }
    
    
    // MARK: Set Device Input
    
    func setDeviceInput() async throws {
        guard let device = self.device else {
            throw AVCaptureError.faildToGetCaptureDevice
        }
        
        // Device Configuration
        do {
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            device.unlockForConfiguration()
        }
        catch {
            throw AVCaptureError.unspecified("ERROR::Failed to configure focusMode.")
        }
        
        // Add Device Input
        do {
            let deviceInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            else {
                throw AVCaptureError.cannotAddDeviceInput
            }
        }
        catch {
            throw AVCaptureError.createCaptureInput(error)
        }
    }
    
    
    // MARK: Set VideoData Output
    
    func setVideoDataOutput() async throws {
        guard session.canAddOutput(videoOutput) else {
            throw AVCaptureError.cannotAddVideoOutput
        }
        self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        // Set Video Output Delegate
        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
        // Add
        session.addOutput(videoOutput)
        // Set Orientation
        if let connection = videoOutput.connection(with: .video),
           connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }
    }
    
}


// MARK: -

private extension AVCaptureManager {
    
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
