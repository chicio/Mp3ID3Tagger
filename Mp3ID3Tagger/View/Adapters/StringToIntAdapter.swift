//
//  StringToIntAdapter.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 14.08.18.
//

import Foundation

class StringToNumberAdapter {
    static func convertToNumber(string: String?) -> Int? {
        if let validString = string {
            return Int(validString)
        }
        return nil
    }
}
