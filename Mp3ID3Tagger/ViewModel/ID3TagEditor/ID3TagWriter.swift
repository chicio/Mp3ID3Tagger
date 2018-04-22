//
//  ID3TagWriter.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 16/04/18.
//

import Foundation
import RxSwift
import ID3TagEditor

class ID3TagWriter {
    private let id3TagEditor: ID3TagEditor
    private let saveAction: Observable<Void>
    private let disposeBag: DisposeBag
    
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
