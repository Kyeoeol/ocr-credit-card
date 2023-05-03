//
//  OCRCaptureResultView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/03.
//

import SwiftUI
import Combine

struct OCRCaptureResultView: View {
    
    // MARK: Properties
    
    @Binding var ocrCaptureResult: OCRCaptureResult?
    @State private var scale: CGFloat = 0.0
    
    
    // MARK: Body
    
    var body: some View {
        VStack(alignment: .leading) {
            // CardNumber
            VStack(alignment: .leading) {
                Text("CardNumber :")
                    .fontWeight(.bold)
                Text(ocrCaptureResult?.cardNumber ?? "")
            }
            .padding(.bottom, 4)
            
            // CardValidDate
            VStack(alignment: .leading) {
                Text("CardValidDate : ")
                    .fontWeight(.bold)
                Text(ocrCaptureResult?.cardValidDate ?? "")
            }
        } //: VStack
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .scaleEffect(scale)
        .onReceive(Just(ocrCaptureResult)) { value in
            guard value != nil else { return }
            withAnimation {
                scale = 1.0
            }
        }
    }
}


// MARK: Previews

struct OCRCaptureResultView_Previews: PreviewProvider {
    static var previews: some View {
        OCRCaptureResultView(ocrCaptureResult: .constant(
            OCRCaptureResult(cardNumber: "1234 1234 1234 1234",
                             cardValidDate: "01/23")
        ))
        .previewLayout(.sizeThatFits)
    }
}
