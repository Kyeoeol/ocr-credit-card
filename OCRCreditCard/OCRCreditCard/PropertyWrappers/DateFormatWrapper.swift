//
//  DateFormatWrapper.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/03.
//

import Foundation

@propertyWrapper
struct DateFormatWrapper {
    
    private var value: String = ""
    private var dateFormat: String
    
    var wrappedValue: String {
        get {
            formatting(inputDateString: value)
        }
        set {
            value = newValue
        }
    }
    
    
    // Initialize
    init(wrappedValue: String, dateFormat: String) {
        self.dateFormat = dateFormat
        self.wrappedValue = wrappedValue
    }
    
    
    // Function
    private func formatting(inputDateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "MM/yy"
        
        guard let inputDate = dateFormatter.date(from: inputDateString) else {
            return ""
            
        }
        
        dateFormatter.dateFormat = dateFormat
        let outputDateString = dateFormatter.string(from: inputDate)
        return outputDateString
    }
    
}
