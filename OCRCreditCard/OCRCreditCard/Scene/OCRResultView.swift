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
        // CIImage
        guard let buffer = cvImageBuffer else {
            return
        }
        guard let ciImage = buffer.createCIImage() else {
            return
        }
        // Guide Size Image
        guard let guideSizeImage = createGuideSizeImage(from: ciImage) else {
            return
        }
        // Perform RecognizeText
        performRecognizeTextRequest(with: guideSizeImage)
    }
    
    
    // MARK: Create GuideSize Image
    func createGuideSizeImage(from ciImage: CIImage) -> CIImage? {
        let scale = windowSize.height / ciImage.extent.height
        let aspectRatio = windowSize.width / (ciImage.extent.width * scale)
        
        guard let ciFilter = CIFilter(name: "CILanczosScaleTransform") else {
            return nil
        }
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue(scale, forKey: kCIInputScaleKey)
        ciFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        
        guard let outputImage = ciFilter.outputImage else {
            return nil
        }
        let guideSizeImage = outputImage.cropped(to: ocrGuideSize)
        return guideSizeImage
    }
    
    
    // MARK: Perform RecognizeText Request
    func performRecognizeTextRequest(with ciImage: CIImage) {
        // Handler
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
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
     카드 번호 검증코드
     위에서 설명한 것 처럼 카드번호의 맨 마지막 숫자는 카드번호의 검증코드이다.
     카드번호 총 16자리 숫자에서(아멕스카드는 15자리) 검증번호 체계는 다음처럼 계산한다.

      1) 마지막 검증코드숫자를 제외하고 그 앞 숫자부터 거꾸로 가면서 2를 곱하고, 그다음은 1을 곱하고, 다시 2와 1 곱하기를
          번갈아 나열해서 곱한다.
     2) 곱셈한 결과가 10을 넘을 경우 다시 숫자끼리 더한다.
         - 예를 들어 7*2 = 14 일 경우 다시 1+4 = 5 로 치환한다.
     3) 모든 숫자의 계산 결과를 모두 더한다.
     4) 합계 숫자의 끝자리 수를 10에서 빼면 검증코드 숫자이다.(끝자리 수가 0인 경우 그냥 0이다.)
         - 예를 들어 합계 숫자가 62이면, 끝자리는 2이고, 검증코드는 10-2= 8이 된다.(합계숫자가 50이면 검증코드는 0이다.)
     */
    func isValidCardNumber(_ cardNumber: String?) -> Bool {
        guard let cardNumber else { return false }
        guard let compareValue = self.getCompareValueForValid(cardNumber) else { return false }
        let compareValideCode = self.getValidCode(compareValue)
        guard let valideCode = self.getValidCode(cardNumber) else { return false }
        return compareValideCode == valideCode
    }
    func getCompareValueForValid(_ cardNumber: String) -> Int? {
        var sum: Int?
        cardNumber.dropLast(1).replacingOccurrences(of: " ", with: "")
            .enumerated().forEach { index, character in
                let singleNumber = String(character)
                guard let number = Int(singleNumber) else { return }

                let baseSum = sum ?? 0
                if index % 2 == 0 {
                    // 10이 넘을 경우 각 자릿수 숫자끼리 더한다.
                    let number = (number * 2).reduceDigits()
                    sum = baseSum + number
                }
                else {
                    sum = baseSum + number
                }
            }
        return sum
    }
    
    func getValidCode(_ value: Int) -> Int {
        let code = value % 10 // 1의 자리 숫자 구함
        if code == 0 { return 0 }
        else { return 10 - code }
    }
    func getValidCode(_ cardNumber: String) -> Int? {
        let lastCardNumber = String(cardNumber.suffix(1))
        return Int(lastCardNumber)
    }
    
} //: OCRResultView


// MARK: Previews

struct OCRResultView_Previews: PreviewProvider {
    static var previews: some View {
        OCRResultView()
    }
}
