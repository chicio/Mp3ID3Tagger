//
//  EmptyStringFormatter.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 21/04/18.
//

import Foundation

class EmptyStringFormatter: NumberFormatter {
    override func isPartialStringValid(_ partialString: String,
                                       newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
                                       errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if partialString.count == 0 {
            return true
        }
        return false
    }
}
