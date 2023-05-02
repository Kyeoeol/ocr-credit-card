//
//  AVCaptureErrorView.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import SwiftUI

struct AVCaptureErrorView: View {
    
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

struct CaptureErrorView_Previews: PreviewProvider {
    static var previews: some View {
        AVCaptureErrorView(error: AVCaptureError.cannotAddDeviceInput)
    }
}
