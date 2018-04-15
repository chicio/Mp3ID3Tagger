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
    let title: Variable<String?>
    let artist: Variable<String?>
    let album: Variable<String?>
    let year: Variable<String?>
    let versionField: VersionField
    let trackPositionInSetFields: TrackPositionInSetFields
    let genreFields: GenreFields
    let attachedPicture: PublishSubject<Data>
    let mp3Paths: Observable<String>
    let saveResult: PublishSubject<Bool>
    
    init(id3TagEditor: ID3TagEditor,
         imageOpenAction: PublishSubject<Data>,
         openAction: Observable<String>,
         saveAction: Observable<Void>) {
        self.id3TagEditor = id3TagEditor
        title = Variable<String?>(nil)
        artist = Variable<String?>(nil)
        album = Variable<String?>(nil)
        year = Variable<String?>(nil)
        self.versionField = VersionField()
        self.trackPositionInSetFields = TrackPositionInSetFields()
        self.genreFields = GenreFields()
        self.saveResult = PublishSubject<Bool>()
        mp3Paths = openAction
        attachedPicture = imageOpenAction
        super.init()

        readMp3Files()
        
        let image = imageOpenAction.map({ (imageData) -> AttachedPicture in
            return AttachedPicture(art: imageData, type: .FrontCover, format: .Png)
        })
        
        let input = Observable.combineLatest(
            title.asObservable(),
            artist.asObservable(),
            album.asObservable(),
            year.asObservable(),
            self.versionField.validVersion,
            self.trackPositionInSetFields.trackPositionInSet,
            self.genreFields.genre,
            image
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
        mp3Paths.subscribe(onNext: { [unowned self] path in
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
        self.title.value = id3Tag?.title
        self.artist.value = id3Tag?.artist
        self.album.value = id3Tag?.album
        self.year.value = id3Tag?.year
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
            attachedPicture.onNext(validAttachedPictures[0].art)
        }
    }
}
