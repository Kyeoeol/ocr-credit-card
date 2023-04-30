//
//  String+Extension.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/04/30.
//

import Foundation

extension String {
    
    enum RegexPattern: String {
        case cardNumber = "[34569][0-9]{14,15}"
        case cardValidDate = "(0[1-9]|1[0-2])/([0-9]{2})"
    }
    
    // MARK: Get Matched Text
    func getMatchedText(pattern: RegexPattern) -> String? {
        // Create a regular expression object from the pattern
        guard let regex = try? NSRegularExpression(pattern: pattern.rawValue, options: []) else {
            return nil
        }
        // Find the first match of the regular expression in the input string
        let range = NSRange(self.startIndex..., in: self)
        guard let match = regex.firstMatch(in: self, options: [], range: range) else {
            return nil
        }
        // Extract the matched substring from the input string
        guard let range = Range(match.range, in: self) else {
            return nil
        }
        let matchedSubstring = String(self[range])
        // return
        return matchedSubstring
    }
    
    
    // MARK: Separated
    func separated(_ length: Int) -> String {
        return stride(from: 0, to: self.count, by: length).map {
            let startIndex = self.index(self.startIndex, offsetBy: $0)
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[startIndex..<endIndex])
        }
        .joined(separator: " ")
    }
    
}
