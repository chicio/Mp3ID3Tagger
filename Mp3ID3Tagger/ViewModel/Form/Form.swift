//
//  Form.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 16/04/18.
//

import Foundation
import RxSwift
import ID3TagEditor

class Form {
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
            versionField.validVersion,
            basicSongFields.observe(),
            trackPositionInSetFields.trackPositionInSet,
            genreFields.genre,
            attachedPictureField.observeAttachPictureCreation()
        ) { (version, basicFields, trackPositionInSet, genre, image) -> ID3Tag in
            return ID3Tag(version: version,
                          artist: basicFields.artist,
                          albumArtist: basicFields.albumArtist,
                          album: basicFields.album,
                          title: basicFields.title,
                          recordingDateTime: RecordingDateTime(date: RecordingDate(day: nil,
                                                                                   month: nil,
                                                                                   year: basicFields.year),
                                                               time: nil),
                          genre: genre,
                          attachedPictures: image,
                          trackPosition: trackPositionInSet)
        }
    }
    
    func fillFields(using id3Tag: ID3Tag?) {
        fillBasicFieldsUsing(id3Tag: id3Tag)
        fillVersionFieldUsing(id3Tag: id3Tag)
        fillTrackPositionFieldsUsing(id3Tag: id3Tag)
        fillGenreFieldsUsing(id3Tag: id3Tag)
        fillAttachedPictureUsing(id3Tag: id3Tag)
    }
    
    private func fillBasicFieldsUsing(id3Tag: ID3Tag?) {
        basicSongFields.title.value = id3Tag?.title
        basicSongFields.artist.value = id3Tag?.artist
        basicSongFields.album.value = id3Tag?.album
        basicSongFields.albumArtist.value = id3Tag?.albumArtist
        if let year = id3Tag?.recordingDateTime?.date?.year {
            basicSongFields.year.value = String(year)
        }
    }
    
    private func fillVersionFieldUsing(id3Tag: ID3Tag?) {
        if let version = id3Tag?.properties.version.rawValue {
            versionField.version.value = Int(version)
        }
    }
    
    private func fillTrackPositionFieldsUsing(id3Tag: ID3Tag?) {
        if let trackPosition = id3Tag?.trackPosition {
            trackPositionInSetFields.trackPosition.value = String(trackPosition.position)
            fillTotalTracksFieldUsing(id3Tag: id3Tag)
        }
    }
    
    private func fillTotalTracksFieldUsing(id3Tag: ID3Tag?) {
        if let totalTracks = id3Tag?.trackPosition?.totalTracks {
            trackPositionInSetFields.totalTracks.value = String(totalTracks)
        }
    }
    
    private func fillGenreFieldsUsing(id3Tag: ID3Tag?) {
        if let genre = id3Tag?.genre {
            genreFields.genreIdentifier.value = genre.identifier?.rawValue
            genreFields.genreDescription.value = genre.description
        }
    }
    
    private func fillAttachedPictureUsing(id3Tag: ID3Tag?) {
        if let validAttachedPictures = id3Tag?.attachedPictures, validAttachedPictures.count > 0 {
            attachedPictureField.attachedPicture.value = ImageWithType(data: validAttachedPictures[0].picture,
                                                                       format: validAttachedPictures[0].format)
        }
    }
}
