//
//  AVCaptureError.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/04/30.
//

import Foundation

enum AVCaptureError: Error {
    case cameraUnavailable
    case cannotAddInput
    case cannotAddOutput
    case createCaptureInput(Error)
    case deniedAuthorization
    case restrictedAuthorization
    case unknownAuthorization
}

extension AVCaptureError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .cameraUnavailable:
          return "Camera unavailable"
        case .cannotAddInput:
          return "Cannot add capture input to session"
        case .cannotAddOutput:
          return "Cannot add video output to session"
        case .createCaptureInput(let error):
          return "Creating capture input for camera:: \(error.localizedDescription)"
        case .deniedAuthorization:
          return "Camera access denied"
        case .restrictedAuthorization:
          return "Attempting to access a restricted capture device"
        case .unknownAuthorization:
          return "Unknown authorization status for capture device"
        }
    }
    
}
