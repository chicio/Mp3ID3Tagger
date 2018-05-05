//
//  TrackPositionInSetViewModelTests.swift
//  Mp3ID3TaggerTests
//
//  Created by Fabrizio Duroni on 14.04.18.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
import ID3TagEditor
@testable import Mp3ID3Tagger

class TrackPositionInSetFieldsTests: XCTestCase {
    func testTrackPositionInSetSetupWithVariousValuesCombination() {
        let disposeBag = DisposeBag()
        let testScheduler = TestScheduler(initialClock: 0)
        let mockTrackPositionObservable = testScheduler.createHotObservable([next(10, "3")])
        let mockTotalTrackObservable = testScheduler.createHotObservable([next(15, "10"), next(20, nil)])
        let observer = testScheduler.createObserver(TrackPositionInSet?.self)

        let trackPositionInSetFields = TrackPositionInSetFields()
        
        testScheduler.scheduleAt(0) {
            mockTrackPositionObservable.bind(to: trackPositionInSetFields.trackPosition).disposed(by: disposeBag)
            mockTotalTrackObservable.bind(to: trackPositionInSetFields.totalTracks).disposed(by: disposeBag)
            trackPositionInSetFields.trackPositionInSet.subscribe(observer).disposed(by: disposeBag)
        }
        
        testScheduler.start()
        
        let result: [TrackPositionInSet?] = observer.events.map { $0.value.element! }
        let expectedTrackPosition: [TrackPositionInSet?] = [
            nil,
            TrackPositionInSet(position: 3, totalTracks: nil),
            TrackPositionInSet(position: 3, totalTracks: 10),
            TrackPositionInSet(position: 3, totalTracks: nil)
        ]
        
        XCTAssertNil(result[0])
        XCTAssertEqual(result[1], expectedTrackPosition[1])
        XCTAssertEqual(result[2], expectedTrackPosition[2])
        XCTAssertEqual(result[3], expectedTrackPosition[3])
    }
}
