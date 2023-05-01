//
//  OCRErrorView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import SwiftUI

struct OCRErrorView: View {
    
    // MARK: Properties
    
    var error: Error?
    
    
    // MARK: Body
    
    var body: some View {
        VStack {
            if let localizedDescription = error?.localizedDescription {
                Text(localizedDescription)
                    .bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Color.red
                            .edgesIgnoringSafeArea(.top)
                    )
            }
            
            Spacer()
        } //: VStack
    }
}


// MARK: Previews

struct OCRErrorView_Previews: PreviewProvider {
    static var previews: some View {
        OCRErrorView(error: AVCaptureError.cannotAddDeviceInput)
    }
}
