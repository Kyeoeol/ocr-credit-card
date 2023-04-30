//
//  Int+Extension.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/04/30.
//

import Foundation

extension Int {
    
    func reduceDigits() -> Int {
        guard self >= 10 else { return self }
        return String(self)
            .compactMap { String($0) }
            .reduce(0) { result, element in
                guard let element = Int(element) else { return 0 }
                return result + element
            }
    }
    
}
