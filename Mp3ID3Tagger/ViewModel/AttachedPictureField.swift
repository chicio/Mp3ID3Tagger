//
//  AttachedPictureField.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 15/04/18.
//

import Foundation
import RxSwift
import ID3TagEditor

class AttachedPictureField {
    let attachedPicture: PublishSubject<ImageWithType>

    init() {
        self.attachedPicture = PublishSubject<ImageWithType>()
    }

    func observeAttachPictureCreation() -> Observable<AttachedPicture> {
        return self.attachedPicture.map({ (imageWithType) -> AttachedPicture in
            return AttachedPicture(art: imageWithType.data, type: .FrontCover, format: imageWithType.format)
        })
    }
}
