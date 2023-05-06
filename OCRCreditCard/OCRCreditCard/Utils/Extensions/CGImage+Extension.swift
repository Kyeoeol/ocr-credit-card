//
//  CGImage+Extension.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/06.
//

import SwiftUI
import VideoToolbox

extension CGImage {
    
    static func create(from buffer: CVPixelBuffer?) -> CGImage? {
        guard let buffer else {
            return nil
        }
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(buffer,
                                         options: nil,
                                         imageOut: &cgImage)
        return cgImage
    }
    
}
