//
//  Mp3ID3TagViewModel.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 13.04.18.
//  Copyright © 2018 Fabrizio Duroni. All rights reserved.
//

import Foundation
import ID3TagEditor
import RxSwift
import RxCocoa

class Mp3ID3TaggerViewModel: ViewModel {
    let title: Variable<String?>
    let artist: Variable<String?>
    let album: Variable<String?>
    let year: Variable<String?>
    let version: Variable<Int?>
    let trackPosition: Variable<String?>
    let totalTracks: Variable<String?>
    let genreIdentifier: Variable<Int?>
    let genreDescription: Variable<String?>
    let save: PublishSubject<Bool>
    
    init(id3TagEditor: ID3TagEditor,
         path: Observable<String>,
         image: PublishSubject<Data>,
         updateAction: Observable<Void>) {
        title = Variable<String?>(nil)
        artist = Variable<String?>(nil)
        album = Variable<String?>(nil)
        year = Variable<String?>(nil)
        version = Variable<Int?>(3)
        trackPosition = Variable<String?>(nil)
        totalTracks = Variable<String?>(nil)
        genreIdentifier = Variable<Int?>(nil)
        genreDescription = Variable<String?>(nil)
        save = PublishSubject<Bool>()
        super.init()
        path.subscribe(onNext: { [unowned self] path in
            let id3Tag = try! id3TagEditor.read(from: path)
            self.version.value = Int(id3Tag!.properties.version.rawValue)
            self.title.value = id3Tag?.title
            self.artist.value = id3Tag?.artist
            self.album.value = id3Tag?.album
            self.year.value = id3Tag?.year
            if let trackPosition = id3Tag?.trackPosition {
                self.trackPosition.value = String(trackPosition.position)
                if let totalTracks = trackPosition.totalTracks {
                    self.totalTracks.value = String(totalTracks)
                }
            }
            if let genre = id3Tag?.genre {
                self.genreIdentifier.value = genre.identifier?.rawValue
                self.genreDescription.value = genre.description
            }
            if let validAttachedPictures = id3Tag?.attachedPictures {
                image.onNext(validAttachedPictures[0].art)
            }
        }).disposed(by: disposeBag)
        
        let validVersion = version.asObservable().map { (versionSelected) -> ID3Version in
            return ID3Version(rawValue: UInt8(versionSelected ?? 0)) ?? .version3
        }
        
        let trackPositionInSet = Observable.combineLatest(
            trackPosition.asObservable(),
            totalTracks.asObservable()
        ) { (trackPosition, totalTracks) -> TrackPositionInSet? in
            if let validTrackPositionAsString = trackPosition,
                let validTrackPosition = Int(validTrackPositionAsString) {
                return TrackPositionInSet(position: validTrackPosition, totalTracks: Int(totalTracks ?? ""))
            }
            return nil
        }
        
        let genre = Observable.combineLatest(
            genreIdentifier.asObservable(),
            genreDescription.asObservable()
        ) { (genreIdentifier, genreDescription) -> Genre? in
            if let validGenre = genreIdentifier,
                let validId3Genre = ID3Genre(rawValue: validGenre) {
                return Genre(genre: validId3Genre, description: genreDescription)
            }
            return nil
        }
        
        let image = image.map({ (imageData) -> AttachedPicture in
            return AttachedPicture(art: imageData, type: .FrontCover, format: .Png)
        })
        
        let input = Observable.combineLatest(
            title.asObservable(),
            artist.asObservable(),
            album.asObservable(),
            year.asObservable(),
            validVersion,
            trackPositionInSet,
            genre,
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
        
        updateAction
            .withLatestFrom(Observable.combineLatest(input, path))
            .subscribe(onNext: { event in
                do {
                    try id3TagEditor.write(tag: event.0, to: event.1)
                    self.save.onNext(true)
                } catch {
                    self.save.onNext(false)
                }
            })
            .disposed(by: disposeBag)
    }
}
