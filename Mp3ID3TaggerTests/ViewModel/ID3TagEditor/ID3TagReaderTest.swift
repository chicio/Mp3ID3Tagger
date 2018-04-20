//
//  ID3TagReaderTest.swift
//  Mp3ID3TaggerTests
//
//  Created by Fabrizio Duroni on 19/04/18.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
import ID3TagEditor
@testable import Mp3ID3Tagger

class ID3TagReaderTest: XCTestCase {
    func testReadNotValidFile() {
        let testScheduler = TestScheduler(initialClock: 0)
        let mockOpenActionObservable = testScheduler.createHotObservable([Recorded.next(2, "::invalid path::")])
        let expectation = XCTestExpectation(description: "Finish tag read")

        let id3TagReader = ID3TagReader(
                id3TagEditor: ID3TagEditor(),
                openAction: mockOpenActionObservable.asObservable()
        )
        id3TagReader.read { tag in
            XCTAssertNil(tag)
            expectation.fulfill()
        }

        testScheduler.start()
        wait(for: [expectation], timeout: 5)
    }

    func testReadValidFile() {
        let mp3Path = PathLoader().pathFor(name: "example", fileType: "mp3")
        let testScheduler = TestScheduler(initialClock: 0)
        let mockOpenActionObservable = testScheduler.createHotObservable([Recorded.next(2, mp3Path)])
        let expectation = XCTestExpectation(description: "Finish tag read")

        let id3TagReader = ID3TagReader(id3TagEditor: ID3TagEditor(), openAction: mockOpenActionObservable.asObservable())
        id3TagReader.read { tag in
            XCTAssertNotNil(tag)
            expectation.fulfill()
        }

        testScheduler.start()
        wait(for: [expectation], timeout: 5)
    }
}
