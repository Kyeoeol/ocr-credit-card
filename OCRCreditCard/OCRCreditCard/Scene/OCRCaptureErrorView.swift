//
//  OCRCaptureErrorView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import SwiftUI

struct OCRCaptureErrorView: View {
    
    // MARK: Properties
    
    var error: Error
    
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(error.localizedDescription)
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
    }
}


// MARK: Previews

struct OCRCaptureErrorView_Previews: PreviewProvider {
    static var previews: some View {
        OCRCaptureErrorView(error: OCRCaptureError.cannotAddDeviceInput)
    }
}
