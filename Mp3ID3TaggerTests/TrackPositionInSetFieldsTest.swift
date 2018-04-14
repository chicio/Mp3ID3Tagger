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
        let mockTrackPositionObserver = testScheduler.createHotObservable([next(10, "3")])
        let mockTotalTrackObserver = testScheduler.createHotObservable([next(15, "10")])
        let observer = testScheduler.createObserver(TrackPositionInSet?.self)

        let trackPositionInSetFields = TrackPositionInSetFields()
        
        testScheduler.scheduleAt(0) {
            mockTrackPositionObserver.bind(to: trackPositionInSetFields.trackPosition).disposed(by: disposeBag)
            mockTotalTrackObserver.bind(to: trackPositionInSetFields.totalTracks).disposed(by: disposeBag)
            trackPositionInSetFields.trackPositionInSet.subscribe(observer).disposed(by: disposeBag)
        }
        
        testScheduler.start()
        
        let result: [TrackPositionInSet?] = observer.events.map({ $0.value.element! })
        let expectedTrackPosition: [TrackPositionInSet?] = [
            nil,
            TrackPositionInSet(position: 3, totalTracks: nil),
            TrackPositionInSet(position: 3, totalTracks: 10)
        ]
        
        XCTAssertNil(result[0])
        XCTAssertEqual(result[1]?.position, expectedTrackPosition[1]?.position)
        XCTAssertEqual(result[1]?.totalTracks, expectedTrackPosition[1]?.totalTracks)
        XCTAssertEqual(result[2]?.position, expectedTrackPosition[2]?.position)
        XCTAssertEqual(result[2]?.totalTracks, expectedTrackPosition[2]?.totalTracks)
    }
}
