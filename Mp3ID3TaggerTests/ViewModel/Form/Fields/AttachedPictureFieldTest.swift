//
//  AttachedPictureFieldTest.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 15/04/18.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
import ID3TagEditor
@testable import Mp3ID3Tagger

class AttachedPictureFieldTest: XCTestCase {
    func testAttachedPictureCreation() {
        let jpeg = try! Data(contentsOf: URL(fileURLWithPath: PathLoader().pathFor(name: "1", fileType: "jpeg")))
        let png = try! Data(contentsOf: URL(fileURLWithPath: PathLoader().pathFor(name: "2", fileType: "png")))
        let disposeBag = DisposeBag()
        let testScheduler = TestScheduler(initialClock: 0)
        let mockImageSelectorObserver = testScheduler.createHotObservable([
            next(10, ImageWithType(data: jpeg, format: .Jpeg)),
            next(15, ImageWithType(data: png, format: .Png))
        ])
        let observer = testScheduler.createObserver([AttachedPicture]?.self)

        let attachedPictureField = AttachedPictureField()

        testScheduler.scheduleAt(0) {
            mockImageSelectorObserver.bind(to: attachedPictureField.attachedPicture).disposed(by: disposeBag)
            attachedPictureField.observeAttachPictureCreation().subscribe(observer).disposed(by: disposeBag)
        }

        testScheduler.start()

        let results: [[AttachedPicture]?] = observer.events.map { $0.value.element! }
        let expectedAttachedPictures: [AttachedPicture] = [
            AttachedPicture(art: jpeg, type: .FrontCover, format: .Jpeg),
            AttachedPicture(art: png, type: .FrontCover, format: .Png)
        ]

        XCTAssertNil(results[0])
        XCTAssertEqual(results[1]?[0].art, expectedAttachedPictures[0].art)
        XCTAssertEqual(results[1]?[0].format, expectedAttachedPictures[0].format)
        XCTAssertEqual(results[1]?[0].type, expectedAttachedPictures[0].type)
        XCTAssertEqual(results[2]?[0].art, expectedAttachedPictures[1].art)
        XCTAssertEqual(results[2]?[0].format, expectedAttachedPictures[1].format)
        XCTAssertEqual(results[2]?[0].type, expectedAttachedPictures[1].type)
    }
}
