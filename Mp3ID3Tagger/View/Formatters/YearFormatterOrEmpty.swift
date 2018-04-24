//
//  FourDigitYearFormatter.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 22/04/18.
//

import Foundation

class YearFormatter: EmptyStringFormatter {
    override func isPartialStringValid(_ partialString: String,
                                       newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
                                       errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if let inputAsNumber = Int(partialString),
            validYear(input: inputAsNumber) {
            return true
        }
        return super.isPartialStringValid(partialString, newEditingString: newString, errorDescription: error)
    }
    
    private func validYear(input: Int) -> Bool {
        return input > 0 && input < 10000
    }
}
