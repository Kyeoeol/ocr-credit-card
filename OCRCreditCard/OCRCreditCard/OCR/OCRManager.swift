//
//  OCRManager.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/01.
//

import SwiftUI
import Combine

final class OCRManager: ObservableObject {
    
    private var cancellable = Set<AnyCancellable>()
    
    
    @Published var frame: CGImage?
    @Published var error: Error?
    
    
    
    
    init() {
        setSubscriptions()
    }
    
    
    
    
    func setSubscriptions() {
        // Current Image Buffer
        AVCaptureManager.shared.$currentImageBuffer
            .receive(on: RunLoop.main)
            .compactMap { CGImage.create(from: $0) }
            .sink { self.frame = $0 }
            .store(in: &cancellable)
        
        // AVCapture Error
        AVCaptureManager.shared.$error
            .receive(on: RunLoop.main)
            .sink { self.error = $0 }
            .store(in: &cancellable)
    }
    
}
