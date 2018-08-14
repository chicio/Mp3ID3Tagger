//
//  ID3TagWriterTest.swift
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

class ID3TagWriterTest: XCTestCase {
    func testWriteValidTagOnValidPath() {
        let mp3Path = PathLoader().pathFor(name: "example", fileType: "mp3")
        let id3Tag = ID3Tag(
                version: .version3,
                artist: "::an artist::",
                albumArtist: "::an album artist::",
                album: "::an album::",
                title: "::a title::",
                recordingDateTime: nil,
                genre: nil,
                attachedPictures: nil,
                trackPosition: nil
        )
        let testScheduler = TestScheduler(initialClock: 0)
        let mockSaveActionObservable = testScheduler.createHotObservable([Recorded.next(4, ())])
        let mockInputObservable = testScheduler.createHotObservable([Recorded.next(3, (id3Tag, mp3Path))])
        let expectation = XCTestExpectation(description: "Finish tag write")

        let id3TagWriter = ID3TagWriter(id3TagEditor: ID3TagEditor(), saveAction: mockSaveActionObservable.asObservable())
        id3TagWriter.write(input: mockInputObservable.asObservable()) { result in
            XCTAssertTrue(result)
            expectation.fulfill()
        }

        testScheduler.start()
        wait(for: [expectation], timeout: 5)
    }
    
    func testWriteInvalidTagOnValidPath() {
        let mp3Path = PathLoader().pathFor(name: "example", fileType: "mp3")
        let id3Tag = ID3Tag(
                version: .version3,
                artist: nil,
                albumArtist: nil,
                album: nil,
                title: nil,
                recordingDateTime: nil,
                genre: nil,
                attachedPictures: nil,
                trackPosition: nil
        )
        let testScheduler = TestScheduler(initialClock: 0)
        let mockSaveActionObservable = testScheduler.createHotObservable([Recorded.next(4, ())])
        let mockInputObservable = testScheduler.createHotObservable([Recorded.next(3, (id3Tag, mp3Path))])
        let expectation = XCTestExpectation(description: "Finish tag write")

        let id3TagWriter = ID3TagWriter(id3TagEditor: ID3TagEditor(), saveAction: mockSaveActionObservable.asObservable())
        id3TagWriter.write(input: mockInputObservable.asObservable()) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }

        testScheduler.start()
        wait(for: [expectation], timeout: 5)
    }
    
    func testWriteValidTagOnInValidPath() {
        let id3Tag = ID3Tag(
            version: .version3,
            artist: "::an artist::",
            albumArtist: "::an album artist::",
            album: "::an album::",
            title: "::a title::",
            recordingDateTime: nil,
            genre: nil,
            attachedPictures: nil,
            trackPosition: nil
        )
        let testScheduler = TestScheduler(initialClock: 0)
        let mockSaveActionObservable = testScheduler.createHotObservable([Recorded.next(4, ())])
        let mockInputObservable = testScheduler.createHotObservable([Recorded.next(3, (id3Tag, "::invalid path::"))])
        let expectation = XCTestExpectation(description: "Finish tag write")
        
        let id3TagWriter = ID3TagWriter(id3TagEditor: ID3TagEditor(), saveAction: mockSaveActionObservable.asObservable())
        id3TagWriter.write(input: mockInputObservable.asObservable()) { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }
        
        testScheduler.start()
        wait(for: [expectation], timeout: 5)
    }
}
