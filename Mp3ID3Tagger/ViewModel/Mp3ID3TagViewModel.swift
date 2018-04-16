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

class FormFields {
    let basicSongFields: BasicSongFields
    let versionField: VersionField
    let trackPositionInSetFields: TrackPositionInSetFields
    let genreFields: GenreFields
    let attachedPictureField: AttachedPictureField

    init() {
        self.basicSongFields = BasicSongFields()
        self.versionField = VersionField()
        self.trackPositionInSetFields = TrackPositionInSetFields()
        self.genreFields = GenreFields()
        self.attachedPictureField = AttachedPictureField()
    }

    func readFields() -> Observable<ID3Tag> {
        return Observable.combineLatest(
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
    }
    
    func fillFields(using id3Tag: ID3Tag?) {
        if let version = id3Tag?.properties.version.rawValue {
            versionField.version.value = Int(version)
        }
        basicSongFields.title.value = id3Tag?.title
        basicSongFields.artist.value = id3Tag?.artist
        basicSongFields.album.value = id3Tag?.album
        basicSongFields.year.value = id3Tag?.year
        if let trackPosition = id3Tag?.trackPosition {
            trackPositionInSetFields.trackPosition.value = String(trackPosition.position)
            if let totalTracks = id3Tag?.trackPosition?.totalTracks {
                trackPositionInSetFields.totalTracks.value = String(totalTracks)
            }
        }
        if let genre = id3Tag?.genre {
            genreFields.genreIdentifier.value = genre.identifier?.rawValue
            genreFields.genreDescription.value = genre.description
        }
        if let validAttachedPictures = id3Tag?.attachedPictures {
            attachedPictureField.attachedPicture.onNext(
                (data: validAttachedPictures[0].art, format: validAttachedPictures[0].format)
            )
        }
    }
}

class ID3TagReader {
    let id3TagEditor: ID3TagEditor
    let openAction: Observable<String>
    let disposeBag: DisposeBag

    init(id3TagEditor: ID3TagEditor, openAction: Observable<String>) {
        self.id3TagEditor = id3TagEditor
        self.openAction = openAction
        self.disposeBag = DisposeBag()
    }

    func read(_ finish: @escaping (ID3Tag?) -> ()) {
        openAction.subscribe(onNext: { [unowned self] path in
            do {
                let id3Tag = try self.id3TagEditor.read(from: path)
                finish(id3Tag)
            } catch {
                finish(nil)
            }
        }).disposed(by: disposeBag)
    }
}

class ID3TagWriter {
    let id3TagEditor: ID3TagEditor
    let saveAction: Observable<Void>
    let disposeBag: DisposeBag
    
    init(id3TagEditor: ID3TagEditor, saveAction: Observable<Void>) {
        self.id3TagEditor = id3TagEditor
        self.saveAction = saveAction
        self.disposeBag = DisposeBag()
    }
    
    func write(input: Observable<(ID3Tag, String)>, _ finish: @escaping (Bool) -> ()) {
        saveAction
            .withLatestFrom(input)
            .subscribe(onNext: { [unowned self] event in
                do {
                    try self.id3TagEditor.write(tag: event.0, to: event.1)
                    finish(true)
                } catch {
                    finish(false)
                }
            })
            .disposed(by: disposeBag)
    }
}

class Mp3ID3TaggerViewModel: ViewModel {
    let id3TagReader: ID3TagReader
    let id3TagWriter: ID3TagWriter
    let formFields: FormFields
    let saveResult: PublishSubject<Bool>
    
    init(openAction: Observable<String>, saveAction: Observable<Void>) {
        self.id3TagReader = ID3TagReader(id3TagEditor: ID3TagEditor(), openAction: openAction)
        self.id3TagWriter = ID3TagWriter(id3TagEditor: ID3TagEditor(), saveAction: saveAction)
        self.formFields = FormFields()
        self.saveResult = PublishSubject<Bool>()
        super.init()

        id3TagReader.read { [unowned self] id3Tag in
            self.formFields.fillFields(using: id3Tag)
        }
        
        id3TagWriter.write(input: Observable.combineLatest(formFields.readFields(), openAction)) { result in
            self.saveResult.onNext(result)
        }
    }
}
