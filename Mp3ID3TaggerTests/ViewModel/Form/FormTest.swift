//
//  FormTest.swift
//  Mp3ID3TaggerTests
//
//  Created by Fabrizio Duroni on 17/04/18.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
import ID3TagEditor
@testable import Mp3ID3Tagger

class FormTest: XCTestCase {
    func testReadFields() {
        let disposeBag = DisposeBag()
        let testScheduler = TestScheduler(initialClock: 0)
        let mockVersionObservable = testScheduler.createHotObservable([Recorded.next(3, 3)])
        let mockTitleObservable = testScheduler.createHotObservable([Recorded.next(4, "::a title::")])
        let mockArtistObservable = testScheduler.createHotObservable([Recorded.next(5, "::an artist::")])
        let mockAlbumObservable = testScheduler.createHotObservable([Recorded.next(10, "::an album::")])
        let mockAlbumArtistObservable = testScheduler.createHotObservable([Recorded.next(12, "::an album artist::")])
        let mockYearObservable = testScheduler.createHotObservable([Recorded.next(15, "2018")])
        let mockTrackPositionObservable = testScheduler.createHotObservable([Recorded.next(20, "1")])
        let mockTotalTracksObservable = testScheduler.createHotObservable([Recorded.next(20, "10")])
        let mockGenreIdentifierObservable = testScheduler.createHotObservable([Recorded.next(25, 1)])
        let mockGenreDescriptionObservable = testScheduler.createHotObservable([Recorded.next(25, "Classic Rock")])
        let mockAttachedPictureObservable = testScheduler.createHotObservable(
            [Recorded.next(30, ImageWithType(data: Data(), .Jpeg))]
        )
        let observer = testScheduler.createObserver(ID3Tag.self)

        let form = Form()

        testScheduler.scheduleAt(0) {
            mockTitleObservable.bind(to: form.basicSongFields.title).disposed(by: disposeBag)
            mockArtistObservable.bind(to: form.basicSongFields.artist).disposed(by: disposeBag)
            mockAlbumObservable.bind(to: form.basicSongFields.album).disposed(by: disposeBag)
            mockAlbumArtistObservable.bind(to: form.basicSongFields.albumArtist).disposed(by: disposeBag)
            mockYearObservable.bind(to: form.basicSongFields.year).disposed(by: disposeBag)
            mockVersionObservable.bind(to: form.versionField.version).disposed(by: disposeBag)
            mockTrackPositionObservable.bind(to: form.trackPositionInSetFields.trackPosition).disposed(by: disposeBag)
            mockTotalTracksObservable.bind(to: form.trackPositionInSetFields.totalTracks).disposed(by: disposeBag)
            mockGenreIdentifierObservable.bind(to: form.genreFields.genreIdentifier).disposed(by: disposeBag)
            mockGenreDescriptionObservable.bind(to: form.genreFields.genreDescription).disposed(by: disposeBag)
            mockAttachedPictureObservable.bind(to: form.attachedPictureField.attachedPicture).disposed(by: disposeBag)
            form.readFields().subscribe(observer).disposed(by: disposeBag)
        }

        testScheduler.start()

        let result: [ID3Tag] = observer.events.map { $0.value.element! }
        let expectedResult: [ID3Tag] = [
            ID3Tag(version: .version3,
                   artist: "::an artist::",
                   albumArtist: "::an album artist::",
                   album: "::an album::",
                   title: "::a title::",
                   recordingDateTime: RecordingDateTime(date: RecordingDate(day: nil, month: nil, year: 2018), time: nil),
                   genre: Genre(genre: .ClassicRock, description: "Classic Rock"),
                   attachedPictures: [AttachedPicture(picture: Data(), type: .FrontCover, format: .Jpeg)],
                   trackPosition: TrackPositionInSet(position: 1, totalTracks: 10))
        ]

        XCTAssertEqual(result[11].title, expectedResult[0].title)
        XCTAssertEqual(result[11].artist, expectedResult[0].artist)
        XCTAssertEqual(result[11].album, expectedResult[0].album)
        XCTAssertEqual(result[11].albumArtist, expectedResult[0].albumArtist)
        XCTAssertEqual(result[11].recordingDateTime?.date?.year, expectedResult[0].recordingDateTime?.date?.year)
        XCTAssertEqual(result[11].properties.version, expectedResult[0].properties.version)
        XCTAssertEqual(result[11].trackPosition?.position, expectedResult[0].trackPosition?.position)
        XCTAssertEqual(result[11].trackPosition?.totalTracks, expectedResult[0].trackPosition?.totalTracks)
        XCTAssertEqual(result[11].genre?.identifier, expectedResult[0].genre?.identifier)
        XCTAssertEqual(result[11].genre?.description, expectedResult[0].genre?.description)
        XCTAssertEqual(result[11].attachedPictures?[0].type, expectedResult[0].attachedPictures?[0].type)
        XCTAssertEqual(result[11].attachedPictures?[0].format, expectedResult[0].attachedPictures?[0].format)
        XCTAssertEqual(result[11].attachedPictures?[0].picture, expectedResult[0].attachedPictures?[0].picture)
    }

    func testFillFields() {
        let disposeBag = DisposeBag()
        let testScheduler = TestScheduler(initialClock: 0)
        let observerVersion = testScheduler.createObserver(Int?.self)
        let observerArtist = testScheduler.createObserver(String?.self)
        let observerAlbum = testScheduler.createObserver(String?.self)
        let observerAlbumArtist = testScheduler.createObserver(String?.self)
        let observerTitle = testScheduler.createObserver(String?.self)
        let observerYear = testScheduler.createObserver(String?.self)
        let observerGenreIdentifier = testScheduler.createObserver(Int?.self)
        let observerGenreDescription = testScheduler.createObserver(String?.self)
        let observerAttachedPicture = testScheduler.createObserver(ImageWithType?.self)
        let observerTrackPosition = testScheduler.createObserver(String?.self)
        let observerTotalTracks = testScheduler.createObserver(String?.self)

        let form = Form()

        testScheduler.scheduleAt(0) {
            form.versionField.version.asObservable().subscribe(observerVersion).disposed(by: disposeBag)
            form.basicSongFields.artist.asObservable().subscribe(observerArtist).disposed(by: disposeBag)
            form.basicSongFields.album.asObservable().subscribe(observerAlbum).disposed(by: disposeBag)
            form.basicSongFields.albumArtist.asObservable().subscribe(observerAlbumArtist).disposed(by: disposeBag)
            form.basicSongFields.title.asObservable().subscribe(observerTitle).disposed(by: disposeBag)
            form.basicSongFields.year.asObservable().subscribe(observerYear).disposed(by: disposeBag)
            form.genreFields.genreIdentifier.asObservable().subscribe(observerGenreIdentifier).disposed(by: disposeBag)
            form.genreFields.genreDescription.asObservable().subscribe(observerGenreDescription).disposed(by: disposeBag)
            form.attachedPictureField.attachedPicture.asObservable().subscribe(observerAttachedPicture).disposed(by: disposeBag)
            form.trackPositionInSetFields.trackPosition.asObservable().subscribe(observerTrackPosition).disposed(by: disposeBag)
            form.trackPositionInSetFields.totalTracks.asObservable().subscribe(observerTotalTracks).disposed(by: disposeBag)
            form.fillFields(using: ID3Tag(
                    version: .version3,
                    artist: "::an artist::",
                    albumArtist: "::an album artist::",
                    album: "::an album::",
                    title: "::a title::",
                    recordingDateTime: RecordingDateTime(date: RecordingDate(day: nil, month: nil, year: 2018), time: nil),
                    genre: Genre(genre: .ClassicRock, description: "Classic Rock"),
                    attachedPictures: [AttachedPicture(picture: Data(), type: .FrontCover, format: .Jpeg)],
                    trackPosition: TrackPositionInSet(position: 1, totalTracks: 10)
            ))
        }
        
        testScheduler.start()

        let version = observerVersion.events.map { $0.value.element! }
        let artist = observerArtist.events.map { $0.value.element! }
        let album = observerAlbum.events.map { $0.value.element! }
        let albumArtist = observerAlbumArtist.events.map { $0.value.element! }
        let title = observerTitle.events.map { $0.value.element! }
        let year = observerYear.events.map { $0.value.element! }
        let genreIdentifier = observerGenreIdentifier.events.map { $0.value.element! }
        let genreDescription = observerGenreDescription.events.map { $0.value.element! }
        let attachedPicture = observerAttachedPicture.events.map { $0.value.element! }
        let trackPosition = observerTrackPosition.events.map { $0.value.element! }
        let totalTracks = observerTotalTracks.events.map { $0.value.element! }

        XCTAssertEqual(version[0], 3)
        XCTAssertEqual(version[1], 3)
        XCTAssertNil(artist[0])
        XCTAssertEqual(artist[1], "::an artist::")
        XCTAssertNil(album[0])
        XCTAssertEqual(album[1], "::an album::")
        XCTAssertNil(albumArtist[0])
        XCTAssertEqual(albumArtist[1], "::an album artist::")
        XCTAssertNil(title[0])
        XCTAssertEqual(title[1], "::a title::")
        XCTAssertNil(year[0])
        XCTAssertEqual(year[1], "2018")
        XCTAssertNil(genreIdentifier[0])
        XCTAssertEqual(genreIdentifier[1], 1)
        XCTAssertNil(genreDescription[0])
        XCTAssertEqual(genreDescription[1], "Classic Rock")
        XCTAssertNil(attachedPicture[0])
        XCTAssertEqual(attachedPicture[1]?.data, Data())
        XCTAssertEqual(attachedPicture[1]?.format, .Jpeg)
        XCTAssertEqual(trackPosition[0], nil)
        XCTAssertEqual(trackPosition[1], "1")
        XCTAssertEqual(totalTracks[0], nil)
        XCTAssertEqual(totalTracks[1], "10")
    }
}

