//
//  OnlyNumberFormatter.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 21/04/18.
//

import Foundation

class OnlyNumberFormatter: NumberFormatter {
    override func isPartialStringValid(_ partialString: String,
                                       newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
                                       errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if let _ = Int(partialString) {
            return true
        }
        return false
    }
}
