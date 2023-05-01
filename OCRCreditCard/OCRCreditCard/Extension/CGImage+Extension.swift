//
//  CGImage+Extension.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import AVFoundation
import VideoToolbox

extension CGImage {
    
    static func create(from cvPixelBuffer: CVPixelBuffer?) -> CGImage? {
        guard let buffer = cvPixelBuffer else {
            return nil
        }
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(
            buffer,
            options: nil,
            imageOut: &cgImage
        )
        return cgImage
    }
    
}
