//
//  OnlyNumberOrEmptyFormatter.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 22/04/18.
//

import Foundation

class OnlyNumberOrEmptyFormatter: OnlyNumberFormatter {
    override func isPartialStringValid(_ partialString: String,
                                       newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
                                       errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if partialString.count == 0 {
            return true
        }
        return super.isPartialStringValid(partialString, newEditingString: newString, errorDescription: error)
    }
}
