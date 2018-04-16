//
//  VersionFieldTest.swift
//  Mp3ID3TaggerTests
//
//  Created by Fabrizio Duroni on 14.04.18.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import RxTest
import ID3TagEditor
@testable import Mp3ID3Tagger

class VersionFieldTest: XCTestCase {
    func testVersionFieldSetupWithValidValue() {
        let disposeBag = DisposeBag()
        let testScheduler = TestScheduler(initialClock: 0)
        let mockVersionObserver = testScheduler.createHotObservable([next(5, 2), next(10, 3)])
        let observer = testScheduler.createObserver(ID3Version.self)
        
        let versionField = VersionField()
        
        testScheduler.scheduleAt(0) {
            mockVersionObserver.bind(to: versionField.version).disposed(by: disposeBag)
            versionField.validVersion.subscribe(observer).disposed(by: disposeBag)
        }
        
        testScheduler.start()
        
        let result: [ID3Version] = observer.events.map { $0.value.element! }
        let expectedResult: [ID3Version] = [.version3, .version2, .version3]
        
        XCTAssertEqual(result[0], expectedResult[0])
        XCTAssertEqual(result[1], expectedResult[1])
        XCTAssertEqual(result[2], expectedResult[2])
    }
}
