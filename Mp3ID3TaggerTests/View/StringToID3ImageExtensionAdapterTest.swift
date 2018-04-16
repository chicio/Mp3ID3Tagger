//
//  StringToID3ImageExtensionAdapterTest.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 15/04/18.
//

import Foundation
import XCTest
import ID3TagEditor
@testable import Mp3ID3Tagger

class StringToID3ImageExtensionAdapterTest: XCTestCase {
    func testAdaptPngExtensionCaseInsensitive() {
        let adapter = StringToID3ImageExtensionAdapter()

        XCTAssertEqual(adapter.adapt(format: "png"), .Png)
        XCTAssertEqual(adapter.adapt(format: "PNG"), .Png)
    }

    func testAdaptJpegExtensionCaseInsensitive() {
        let adapter = StringToID3ImageExtensionAdapter()

        XCTAssertEqual(adapter.adapt(format: "jpg"), .Jpeg)
        XCTAssertEqual(adapter.adapt(format: "JPG"), .Jpeg)
        XCTAssertEqual(adapter.adapt(format: "jpeg"), .Jpeg)
        XCTAssertEqual(adapter.adapt(format: "JPEG"), .Jpeg)
    }
}

