//
//  StringToID3ImageExtensionAdapter.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 15/04/18.
//

import Foundation
import ID3TagEditor

class StringToID3ImageExtensionAdapter {
    func adapt(format: String) -> ID3PictureFormat {
        return format.caseInsensitiveCompare("png") == ComparisonResult.orderedSame ? .Png : .Jpeg
    }
}
