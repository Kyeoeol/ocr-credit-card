//
//  OCRManager.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/06.
//

import SwiftUI
import Combine
import Vision

final class OCRManager: ObservableObject {
    
    // MARK: Properties
    
    @Published var error: Error?
    @Published var frameImage: CGImage?
    @Published var resultData: OCRResultData?
    
    
    private var cancellable = Set<AnyCancellable>()
    private let captureManager: AVCaptureManager
    private var windowSize: CGSize = .zero
    private var guideSize: CGRect = .zero
    
    
    
    
    // MARK: Initialize
    
    init() {
        captureManager = AVCaptureManager.shared
        subscriptions()
    }
    
    
    // MARK: Subscriptions
    
    private func subscriptions() {
        captureManager.$error
            .compactMap { $0 }
            .sink { self.error = $0 }
            .store(in: &cancellable)

        
        let currentBuffer = captureManager.$currentBuffer.share()
        
        currentBuffer
            .compactMap { CGImage.create(from: $0) }
            .sink {
                self.frameImage = $0
            }
            .store(in: &cancellable)
        
        currentBuffer
            .compactMap { $0 }
            .compactMap { CIImage(cvImageBuffer: $0) }
            .sink { bufferImage in
                self.requestRecognizeText(with: bufferImage)
            }
            .store(in: &cancellable)
    }
    
    
    
    
    // MARK: Set Guide Size
    
    func setGuideSize(windowSize: CGSize, guideSize: CGRect) {
        self.windowSize = windowSize
        self.guideSize = guideSize
        print("TEST::windowSize", windowSize)
    }
    
    // MARK: Start OCR
    
    func startOCR() {
        captureManager.startSession()
    }
    
    
    // MARK: Stop OCR
    
    func stopOCR() {
        captureManager.stopSession()
    }
    
}


// MARK: - Request Recognize Text

private extension OCRManager {
    
    func requestRecognizeText(with ciImage: CIImage) {
        guard let ciImage = getGuideSizeImage(from: ciImage) else {
            return
        }

        // Handler
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

        // Request
        let request = VNRecognizeTextRequest { [weak self] request, error in
            if let error {
                self?.error = OCRError.requestRecognizeText(error)
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            guard observations.isEmpty == false else {
                return
            }

            let topCandidates = observations.compactMap { $0.topCandidates(1) }
            let recognizedText = topCandidates.flatMap { $0 }
                .filter { $0.confidence > 0.5 }
                .compactMap {
                    $0.string.replacingOccurrences(
                        of: "[^0-9/]",
                        with: "",
                        options: .regularExpression
                    )
                }
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
            self.error = OCRError.requestRecognizeText(error)
        }
    }
    
    
    // MARK:  Get GuideSize Image
    
    func getGuideSizeImage(from ciImage: CIImage) -> CIImage? {
        guard windowSize != .zero, guideSize != .zero else {
            error = OCRError.faildToGetGuideSize
            return nil
        }
        
        let scale = CGFloat(windowSize.height) / ciImage.extent.height
        let aspectRatio = CGFloat(windowSize.width) / (ciImage.extent.width * scale)
        
        guard let ciFilter = CIFilter(name: "CILanczosScaleTransform") else { return nil }
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue(scale, forKey: kCIInputScaleKey)
        ciFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        
        guard let outputImage = ciFilter.outputImage else { return nil }
        
        return outputImage.cropped(to: guideSize)
    }
    
    
    // MARK: Extract Card Info
    
    func extractCardInfo(from recognizedText: String) {
        let cardNumber = Just(recognizedText.getMatchedText(pattern: .cardNumber))
            .compactMap { $0 }
            .filter { $0.isValidCardNumber }
        
        let cardValidDate = Just(recognizedText.getMatchedText(pattern: .cardValidDate))
            .compactMap { $0 }
        
        cardNumber
            .zip(cardValidDate)
            .receive(on: DispatchQueue.main)
            .compactMap { cardNumber, cardValidDate in
                return OCRResultData(
                    cardNumber: cardNumber,
                    cardValidDate: cardValidDate
                )
            }
            .sink { resultData in
                self.resultData = resultData
            }
            .store(in: &cancellable)
    }
    
}
