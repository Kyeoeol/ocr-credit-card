//
//  OCRErrorView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import SwiftUI

struct OCRErrorView: View {
    
    // MARK: Properties
    
    @Binding var error: Error?
    
    private var opacity: CGFloat {
        return error == nil ? 0.0 : 1.0
    }
    private var errorMessage: String {
        return error?.localizedDescription ?? ""
    }
    
    
    // MARK: Body
    
    var body: some View {
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
        .opacity(opacity)
    }
}


// MARK: Previews

struct OCRErrorView_Previews: PreviewProvider {
    static var previews: some View {
        OCRErrorView(error: .constant(AVCaptureError.cannotAddDeviceInput))
    }
}
