//
//  VersionField.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 15/04/18.
//

import Foundation
import RxSwift
import ID3TagEditor

class VersionField {
    let version: Variable<Int?>
    let validVersion: Observable<ID3Version>

    init() {
        self.version = Variable<Int?>(3)
        self.validVersion = version.asObservable().map { (versionSelected) -> ID3Version in
            return ID3Version(rawValue: UInt8(versionSelected ?? 0)) ?? .version3
        }
    }
}
