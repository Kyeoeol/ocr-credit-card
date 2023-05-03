//
//  DigitSpaces.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/03.
//

import Foundation

@propertyWrapper
struct DigitSpaces {
    
    private var value: String = ""
    private var spaceEvery: Int
    
    var wrappedValue: String {
        get {
            splitStringIntoDigitSpaces(inputString: value)
        }
        set {
            value = newValue.filter { $0.isNumber }
        }
    }
    
    
    // Initialize
    init(wrappedValue: String, spaceEvery: Int) {
        self.spaceEvery = spaceEvery
        self.wrappedValue = wrappedValue
    }
    
    
    // Function
    private func splitStringIntoDigitSpaces(inputString: String) -> String {
        var resultString = ""
        
        // Iterate over the characters in the input string
        for (index, character) in inputString.enumerated() {
            // Add a space every 4 characters, except for the first character
            if index > 0 && index % spaceEvery == 0 {
                resultString += " "
            }
            // Add the current character to the result string
            resultString.append(character)
        }
        return resultString
    }
    
}
