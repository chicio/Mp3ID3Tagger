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
    let attachedPicture: Variable<ImageWithType?>

    init() {
        self.attachedPicture = Variable<ImageWithType?>(nil)
    }

    func observeAttachPictureCreation() -> Observable<[AttachedPicture]?> {
        return attachedPicture
            .asObservable()
            .map({ imageWithType in
                if let validImageWithType = imageWithType {
                    return [AttachedPicture(picture: validImageWithType.data,
                                            type: .FrontCover,
                                            format: validImageWithType.format)]
                } else {
                    return nil
                }
            })
    }
}
