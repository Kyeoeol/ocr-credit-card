//
//  OCRResultDataModel.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/03.
//

import Foundation

struct OCRResultData {
    @DigitSpaces(spaceEvery: 4)
    var cardNumber: String = ""
    
    @DateFormatWrapper(dateFormat: "yyyy년 MM월")
    var cardValidDate: String = ""
}
