//
//  BasicSongFields.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 15/04/18.
//

import Foundation
import RxSwift

typealias BasicSongFieldsValues = (title: String?, artist: String?, album: String?, albumArtist: String?, year: Int?)

class BasicSongFields {
    let title: Variable<String?>
    let artist: Variable<String?>
    let album: Variable<String?>
    let albumArtist: Variable<String?>
    let year: Variable<String?>
    
    init() {
        self.title = Variable<String?>(nil)
        self.artist = Variable<String?>(nil)
        self.album = Variable<String?>(nil)
        self.albumArtist = Variable<String?>(nil)
        self.year = Variable<String?>(nil)
    }
    
    func observe() -> Observable<BasicSongFieldsValues> {
        return Observable.combineLatest(
            title.asObservable(),
            artist.asObservable(),
            album.asObservable(),
            albumArtist.asObservable(),
            year.asObservable()
        ) { title, artist, album, albumArtist, year in
            return BasicSongFieldsValues(title: title,
                                         artist: artist,
                                         album: album,
                                         albumArtist: albumArtist,
                                         year: StringToNumberAdapter.convertToNumber(string: year))
        }
    }
}
