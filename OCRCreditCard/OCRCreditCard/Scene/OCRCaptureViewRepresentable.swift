//
//  OCRCaptureViewRepresentable.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/02.
//

import AVFoundation
import SwiftUI
import Vision

struct OCRCaptureViewRepresentable: UIViewRepresentable {

    // MARK: Properties
    
    @Environment(\.ocrGuideSize) var ocrGuideSize
    
    @Binding var error: OCRCaptureError?
    @Binding var cardNumber: String?
    @Binding var cardValidDate: String?

    // AVCaptureSession
    var session: AVCaptureSession
    var sessionQueue: DispatchQueue
    // Video Output
    var videoOutput: AVCaptureVideoDataOutput
    // Capture Device
    var device: AVCaptureDevice?
    // PreviewLayerSize
    var previewLayerSize: CGSize
    
    
    
    
    // MARK: Coordinator
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        
        // Properties
        @Binding private var cardNumber: String?
        @Binding private var cardValidDate: String?
        private var previewLayerSize: CGSize
        private var ocrGuideSize: CGSize
        
        
        // Initialize
        init(
            cardNumber: Binding<String?>,
            cardValidDate: Binding<String?>,
            previewLayerSize: CGSize,
            ocrGuideSize: CGSize
        ) {
            self._cardNumber = cardNumber
            self._cardValidDate = cardValidDate
            self.previewLayerSize = previewLayerSize
            self.ocrGuideSize = ocrGuideSize
        }
        
        
        // Capture Output
        func captureOutput(
            _ output: AVCaptureOutput,
            didOutput sampleBuffer: CMSampleBuffer,
            from connection: AVCaptureConnection
        ) {
            guard let buffer = sampleBuffer.imageBuffer else { return }
            processRecognizeText(with: buffer)
        }
        
        
        // MARK: Process RecognizeText
        private func processRecognizeText(with cvImageBuffer: CVImageBuffer) {
            // CIImage
            let ciImage = CIImage(cvImageBuffer: cvImageBuffer)
            // Guide Size Image
            guard let guideSizeImage = getGuideSizeImage(from: ciImage) else {
                return
            }
            // Perform RecognizeText
            performRecognizeTextRequest(with: guideSizeImage)
        }
        
        // MARK: Get GuideSize Image
        func getGuideSizeImage(from ciImage: CIImage) -> CIImage? {
            let scale = CGFloat(previewLayerSize.height) / ciImage.extent.height
            let aspectRatio = CGFloat(previewLayerSize.width) / (ciImage.extent.width * scale)
            
            guard let ciFilter = CIFilter(name: "CILanczosScaleTransform") else { return nil }
            ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
            ciFilter.setValue(scale, forKey: kCIInputScaleKey)
            ciFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
            
            guard let outputImage = ciFilter.outputImage else { return nil }
            let width = CGFloat(ocrGuideSize.width)
            let height = CGFloat(ocrGuideSize.height)
            let x = (CGFloat(previewLayerSize.width) / 2) - (width / 2)
            let y = (CGFloat(previewLayerSize.height) / 2) - (height / 2)
            let finalCIImage = outputImage.cropped(to: CGRect(
                x: x,
                y: y,
                width: width,
                height: height
            ))
            
            return finalCIImage
        }
        
        // MARK: Perform RecognizeText Request
        func performRecognizeTextRequest(with ciImage: CIImage) {
            // Handler
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            // Request
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard error == nil else {
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    return
                }
                guard observations.isEmpty == false else { return }
                
                let topCandidates = observations.compactMap { $0.topCandidates(1) }
                let recognizedText = topCandidates.flatMap { $0 }
                    .filter { $0.confidence > 0.5 }
                    .compactMap { $0.string.replacingOccurrences(of: "[^0-9/]", with: "", options: .regularExpression) }
                    .joined()
                
                // Extract Card Info
                self?.extractCardInfo(from: recognizedText)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            // Proccess Request
            do {
                try handler.perform([request])
            }
            catch {
                // ...
            }
        }
        
        // MARK: Extract Card Info
        func extractCardInfo(from recognizedText: String) {
            self.getCardNumber(recognizedText)
            self.getCardValidDate(recognizedText)
        }
        func getCardNumber(_ text: String) {
            guard let cardNumber = text.getMatchedText(pattern: .cardNumber) else { return }
            guard cardNumber.isValidCardNumber else { return }
            self.cardNumber = cardNumber.separated(4)
        }
        func getCardValidDate(_ text: String) {
            guard let cardValidDate = text.getMatchedText(pattern: .cardValidDate) else { return }
            self.cardValidDate = cardValidDate
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            cardNumber: $cardNumber,
            cardValidDate: $cardValidDate,
            previewLayerSize: previewLayerSize,
            ocrGuideSize: ocrGuideSize
        )
    }
    
    
    
    
    // MARK: makeUIView
    
    func makeUIView(context: Context) -> some UIView {
        let previewView = UIView()
        
        // So far, this is pretty straightforward.
        // But it’s worth noting that any time you want to change something about an AVCaptureSession configuration,
        // you need to enclose that code between a beginConfiguration and a commitConfiguration.
        session.beginConfiguration()
        do {
            session.commitConfiguration()
        }
        
        // AVCaptureDevice
        guard let device = self.device else {
            error = .faildToGetCaptureDevice
            return UIView()
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
            self.error = .unspecified("Failed to configure focusMode.")
            return UIView()
        }
        
        // Add Device Input
        do {
            let deviceInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            else {
                error = .cannotAddDeviceInput
                return UIView()
            }
        }
        catch {
            self.error = .createCaptureInput(error)
            return UIView()
        }
        
        // Add Video Output
        if session.canAddOutput(videoOutput) {
            // Video Settings
            self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
            // Set Video Output Delegate
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue.main)
            // Add
            session.addOutput(videoOutput)
            // Set Orientation
            if let connection = videoOutput.connection(with: AVMediaType.video),
               connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
        else {
            error = .cannotAddVideoOutput
            return UIView()
        }
        
        
        // Add PreviewLayer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: previewLayerSize.width,
            height: previewLayerSize.height
        )
        previewLayer.videoGravity = .resizeAspectFill
        previewView.layer.addSublayer(previewLayer)
        
        // Start Running
        sessionQueue.async {
            self.session.startRunning()
        }
        
        return previewView
    }
    
    
    
    
    // MARK: updateUIView
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // ...
    }
    
}
