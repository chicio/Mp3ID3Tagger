//
//  Mp3ID3TagViewModel.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 13/04/18.
//

import Foundation
import ID3TagEditor
import RxSwift
import RxCocoa

class Mp3ID3TaggerViewModel: ViewModel {
    let id3TagEditor: ID3TagEditor
    let basicSongFields: BasicSongFields
    let versionField: VersionField
    let trackPositionInSetFields: TrackPositionInSetFields
    let genreFields: GenreFields
    let attachedPictureField: AttachedPictureField
    let openAction: Observable<String>
    let saveResult: PublishSubject<Bool>
    
    init(id3TagEditor: ID3TagEditor,
         openAction: Observable<String>,
         saveAction: Observable<Void>) {
        self.id3TagEditor = id3TagEditor
        self.basicSongFields = BasicSongFields()
        self.versionField = VersionField()
        self.trackPositionInSetFields = TrackPositionInSetFields()
        self.genreFields = GenreFields()
        self.attachedPictureField = AttachedPictureField()
        self.saveResult = PublishSubject<Bool>()
        self.openAction = openAction
        super.init()

        readMp3Files()
        
        let input = Observable.combineLatest(
            basicSongFields.title.asObservable(),
            basicSongFields.artist.asObservable(),
            basicSongFields.album.asObservable(),
            basicSongFields.year.asObservable(),
            versionField.validVersion,
            trackPositionInSetFields.trackPositionInSet,
            genreFields.genre,
            attachedPictureField.observeAttachPictureCreation()
        ) { (title, artist, album, year, version, trackPositionInSet, genre, image) -> ID3Tag in
            return ID3Tag(
                version: version,
                artist: artist,
                album: album,
                title: title,
                year: year,
                genre: genre,
                attachedPictures: [image],
                trackPosition: trackPositionInSet
            )
        }
        
        saveAction
            .withLatestFrom(Observable.combineLatest(input, openAction))
            .subscribe(onNext: { [unowned self] event in
                do {
                    try self.id3TagEditor.write(tag: event.0, to: event.1)
                    self.saveResult.onNext(true)
                } catch {
                    self.saveResult.onNext(false)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func readMp3Files() {
        openAction.subscribe(onNext: { [unowned self] path in
            do {
                try self.readMp3FileFrom(path: path)
            } catch {
                print("error open file")
            }
        }).disposed(by: disposeBag)
    }
    
    private func readMp3FileFrom(path: String) throws {
        let id3Tag = try id3TagEditor.read(from: path)
        self.versionField.version.value = Int(id3Tag!.properties.version.rawValue)
        self.basicSongFields.title.value = id3Tag?.title
        self.basicSongFields.artist.value = id3Tag?.artist
        self.basicSongFields.album.value = id3Tag?.album
        self.basicSongFields.year.value = id3Tag?.year
        if let trackPosition = id3Tag?.trackPosition {
            self.trackPositionInSetFields.trackPosition.value = String(trackPosition.position)
            if let totalTracks = id3Tag?.trackPosition?.totalTracks {
                self.trackPositionInSetFields.totalTracks.value = String(totalTracks)
            }
        }
        if let genre = id3Tag?.genre {
            self.genreFields.genreIdentifier.value = genre.identifier?.rawValue
            self.genreFields.genreDescription.value = genre.description
        }
        if let validAttachedPictures = id3Tag?.attachedPictures {
            attachedPictureField.attachedPicture.onNext(
                (data: validAttachedPictures[0].art, format: validAttachedPictures[0].format)
            )
        }
    }
}
