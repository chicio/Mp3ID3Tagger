//
//  ID3TagReader.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 16/04/18.
//

import Foundation
import RxSwift
import ID3TagEditor

class ID3TagReader {
    private let id3TagEditor: ID3TagEditor
    private let openAction: Observable<String>
    private let disposeBag: DisposeBag
    
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
