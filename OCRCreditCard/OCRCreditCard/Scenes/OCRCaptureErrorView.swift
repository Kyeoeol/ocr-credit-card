//
//  OCRCaptureErrorView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import SwiftUI

struct OCRCaptureErrorView: View {
    
    // MARK: Properties
    
    var error: Error?
    
    private var opacity: CGFloat {
        return error == nil ? 0.0 : 1.0
    }
    private var errorMessage: String {
        return error?.localizedDescription ?? ""
    }
    
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(errorMessage)
                    .bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Color.red
                            .edgesIgnoringSafeArea(.top)
                    )
                
                Spacer()
            } //: VStack
        } //: ZStack
        .opacity(opacity)
    }
}


// MARK: Previews

struct OCRCaptureErrorView_Previews: PreviewProvider {
    static var previews: some View {
        OCRCaptureErrorView(error: AVCaptureError.cannotAddDeviceInput)
    }
}
