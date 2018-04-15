//
//  BasicSongFields.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 15/04/18.
//

import Foundation
import RxSwift

class BasicSongFields {
    let title: Variable<String?>
    let artist: Variable<String?>
    let album: Variable<String?>
    let year: Variable<String?>
    
    init() {
        self.title = Variable<String?>(nil)
        self.artist = Variable<String?>(nil)
        self.album = Variable<String?>(nil)
        self.year = Variable<String?>(nil)
    }
}
