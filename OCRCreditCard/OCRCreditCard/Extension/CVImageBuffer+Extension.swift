//
//  CVImageBuffer+Extension.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import SwiftUI
import VideoToolbox

extension CVImageBuffer {
    
    func createCGImage() -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(
            self,
            options: nil,
            imageOut: &cgImage
        )
        return cgImage
    }
    
    func createCIImage() -> CIImage? {
        return CIImage(cvImageBuffer: self)
    }
    
}
