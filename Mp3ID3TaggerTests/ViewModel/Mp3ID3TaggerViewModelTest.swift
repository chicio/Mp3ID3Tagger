//
//  Mp3ID3TaggerViewModelTest.swift
//  Mp3ID3TaggerTests
//
//  Created by Fabrizio Duroni on 20/04/18.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
import ID3TagEditor
@testable import Mp3ID3Tagger

class Mp3ID3TaggerViewModelTest: XCTestCase {
    func testInit() {
        let disposeBag = DisposeBag()
        let mp3Path = PathLoader().pathFor(name: "example", fileType: "mp3")
        let testScheduler = TestScheduler(initialClock: 0)
        let mockOpenActionObservable = testScheduler.createHotObservable([Recorded.next(2, mp3Path)])
        let mockSaveActionObservable = testScheduler.createHotObservable([Recorded.next(4, ())])
        let observer = testScheduler.createObserver(Bool.self)
        
        let mp3Id3TaggerViewModel = Mp3ID3TaggerViewModel(
            openAction: mockOpenActionObservable.asObservable(),
            saveAction: mockSaveActionObservable.asObservable()
        )
        
        testScheduler.scheduleAt(0) {
            mp3Id3TaggerViewModel.saveResult.subscribe(observer).disposed(by: disposeBag)
        }
        
        testScheduler.start()
        
        let result: [Bool] = observer.events.map { $0.value.element! }
        XCTAssertTrue(result[0])
    }
}
