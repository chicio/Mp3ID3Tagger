//
//  GenreFields.swift
//  Mp3ID3TaggerTests
//
//  Created by Fabrizio Duroni on 14/04/18.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
import ID3TagEditor
@testable import Mp3ID3Tagger

class GenreFieldsTest: XCTestCase {
    func testGenreFieldsSetupWithVariousValuesCombination() {
        let disposeBag = DisposeBag()
        let testScheduler = TestScheduler(initialClock: 0)
        let mockGenreIdentifierObserver = testScheduler.createHotObservable([next(10, 1)])
        let mockGenreDescriptionObserver = testScheduler.createHotObservable([next(15, "Classical rock")])
        let observer = testScheduler.createObserver(Genre?.self)
        
        let genreFields = GenreFields()
        
        testScheduler.scheduleAt(0) {
            mockGenreIdentifierObserver.bind(to: genreFields.genreIdentifier).disposed(by: disposeBag)
            mockGenreDescriptionObserver.bind(to: genreFields.genreDescription).disposed(by: disposeBag)
            genreFields.genre.subscribe(observer).disposed(by: disposeBag)
        }
        
        testScheduler.start()
        
        let result: [Genre?] = observer.events.map { $0.value.element! }
        let expectedTrackPosition: [Genre?] = [
            nil,
            Genre(genre: ID3Genre(rawValue: 1), description: nil),
            Genre(genre: ID3Genre(rawValue: 1), description: "Classical rock")
        ]
        
        XCTAssertNil(result[0])
        XCTAssertEqual(result[1]?.identifier, expectedTrackPosition[1]?.identifier)
        XCTAssertEqual(result[1]?.description, expectedTrackPosition[1]?.description)
        XCTAssertEqual(result[2]?.identifier, expectedTrackPosition[2]?.identifier)
        XCTAssertEqual(result[2]?.description, expectedTrackPosition[2]?.description)
    }
}
