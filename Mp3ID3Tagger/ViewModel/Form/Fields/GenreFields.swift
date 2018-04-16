//
//  GenreFields.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 14.04.18.
//

import Foundation
import ID3TagEditor
import RxSwift

class GenreFields {
    let genreIdentifier: Variable<Int?>
    let genreDescription: Variable<String?>
    let genre: Observable<Genre?>
    
    init() {
        self.genreIdentifier = Variable<Int?>(nil)
        self.genreDescription = Variable<String?>(nil)
        self.genre = Observable.combineLatest(
            genreIdentifier.asObservable(),
            genreDescription.asObservable()
        ) { (genreIdentifier, genreDescription) -> Genre? in
            if let validGenre = genreIdentifier,
                let validId3Genre = ID3Genre(rawValue: validGenre) {
                return Genre(genre: validId3Genre, description: genreDescription)
            }
            return nil
        }
    }
}
