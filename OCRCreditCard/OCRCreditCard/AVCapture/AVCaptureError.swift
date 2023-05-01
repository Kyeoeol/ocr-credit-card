//
//  AVCaptureError.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/04/30.
//

import Foundation

enum AVCaptureError: Error {
    case faildToGetCaptureDevice
    case cannotAddDeviceInput
    case cannotAddVideoOutput
    case createCaptureInput(Error)
    case deniedAuthorization
    case restrictedAuthorization
    case unknownAuthorization
}

extension AVCaptureError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .faildToGetCaptureDevice:
          return "Faild to get capture device."
        case .cannotAddDeviceInput:
          return "Cannot add capture device input to session."
        case .cannotAddVideoOutput:
          return "Cannot add capture video output to session."
        case .createCaptureInput(let error):
          return "Creating capture device input: \(error.localizedDescription)"
        case .deniedAuthorization:
          return "Capture device access denied."
        case .restrictedAuthorization:
          return "Attempting to access a restricted capture device."
        case .unknownAuthorization:
          return "Unknown authorization status for capture device."
        }
    }
    
}
