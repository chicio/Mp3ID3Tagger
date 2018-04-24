//
//  OnlyNumberOrEmptyFormatter.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 22/04/18.
//

import Foundation

class OnlyNumberOrEmptyFormatter: EmptyStringFormatter {
    override func isPartialStringValid(_ partialString: String,
                                       newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
                                       errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if let _ = Int(partialString) {
            return true
        }
        return super.isPartialStringValid(partialString, newEditingString: newString, errorDescription: error)
    }
}
