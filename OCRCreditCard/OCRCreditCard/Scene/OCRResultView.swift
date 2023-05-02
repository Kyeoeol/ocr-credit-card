//
//  OCRResultView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import SwiftUI
import Combine
import Vision

struct OCRResultView: View {
    
    // MARK: Properties
    
    @Environment(\.windowSize) private var windowSize
    @Environment(\.ocrGuideSize) private var ocrGuideSize
    @State private var cardNumber = ""
    
    var buffer: CVImageBuffer?
    
    
    // MARK: Body
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(cardNumber)
                .bold()
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Color.white
                        .edgesIgnoringSafeArea(.bottom)
                )
        } //: VStack
        .onReceive(Just(buffer)) { buffer in
            processRecognizeText(with: buffer)
        }
    }
}


// MARK: Functions

private extension OCRResultView {
    
    // MARK: Process RecognizeText
    func processRecognizeText(with cvImageBuffer: CVImageBuffer?) {
        guard let buffer = cvImageBuffer else {
            return
        }
        // CGImage
        guard let cgImage = buffer.createCGImage() else {
            return
        }
        // Guide Size Image
        guard let guideSizeImage = createGuideSizeImage(from: cgImage) else {
            return
        }
        // Perform RecognizeText
        performRecognizeTextRequest(with: guideSizeImage)
    }
    
    
    // MARK: Create GuideSize Image
    func createGuideSizeImage(from cgImage: CGImage) -> CGImage? {
        return cgImage.cropping(to: ocrGuideSize)
    }
    
    
    // MARK: Perform RecognizeText Request
    func performRecognizeTextRequest(with cgImage: CGImage) {
        // Handler
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: .right,
            options: [:]
        )
        
        // Request
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
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
                .filter { $0.confidence > 0.3 }
                .compactMap {
                    $0.string.replacingOccurrences(
                        of: "[^0-9/]",
                        with: "",
                        options: .regularExpression
                    )
                }
                .joined()
            
            // Extract Card Info
            extractCardInfo(from: recognizedText)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        // Proccess Request
        do {
            try handler.perform([request])
        }
        catch {
            print("ERROR::", error)
        }
    } //: performRecognizeTextRequest
    
    
    // MARK: Extract Card Info
    func extractCardInfo(from recognizedText: String) {
        guard recognizedText.isEmpty == false else { return }
        guard let cardNumber = recognizedText.getMatchedText(pattern: .cardNumber) else {
            return
        }
        guard isValidCardNumber(cardNumber) else { return }
        // TODO: -
        self.cardNumber = cardNumber
    }
    
    
    // MARK: Card Number Verification
    /*
     - Luhn’s Algorithm(룬 알고리즘)
     - IBM의 Hans Peter Luhn가 발명했으며, 신용카드 번호 등 식별용 번호가 유효한지 확인하기 위한 알고리즘이다.
     - 암호화 해시 함수처럼 악의적인 공격을 막기 위한 것이 아니라, 번호 오기입 등 우연한 실수를 방지하기 위해 고안되었다.
     - 카드 종류에 따라 룬 알고리즘으로 유효성을 판별할 수 없는 경우도 있다.(ex. 삼성카드에서 발급한 법인카드)
     
     1. 뒤에서 2번째 자리 숫자부터 시작해, 하나씩 건너뛰면서 2를 곱해준 뒤, 모든 digit을 합산한다.
        (각 digit의 합산이므로 2를 곱한 결과가 12인 경우 12가 아닌 1과 2를 각각 더한다.)
     2. 2로 곱하지 않은 모든 digit을 합산한다.
     3. 총 합계의 마지막 자리가 0이라면(즉 합계 모듈로 10의 결과가 0이라면) 유효한 숫자이다.
     */
    func isValidCardNumber(_ cardNumber: String?) -> Bool {
        guard let cardNumber else { return false }
        var sum = 0
        var alternate = false
        let reversedCardNumber = cardNumber.reversed().map { String($0) }
        
        for digit in reversedCardNumber {
            guard let value = Int(digit) else { return false }
            if alternate {
                sum += (value * 2 > 9) ? (value * 2 - 9) : (value * 2)
            } else {
                sum += value
            }
            alternate.toggle()
        }
        
        return sum % 10 == 0
    }
    
} //: OCRResultView


// MARK: Previews

struct OCRResultView_Previews: PreviewProvider {
    static var previews: some View {
        OCRResultView()
    }
}
