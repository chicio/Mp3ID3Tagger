//
//  Mp3ID3TaggerViewModelTest.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 13/04/18.
//

import Foundation
import ID3TagEditor
import RxSwift
import RxCocoa

class Mp3ID3TaggerViewModel: ViewModel {
    let id3TagReader: ID3TagReader
    let id3TagWriter: ID3TagWriter
    let form: Form
    let saveResult: PublishSubject<Bool>
    
    init(openAction: Observable<String>, saveAction: Observable<Void>) {
        self.id3TagReader = ID3TagReader(id3TagEditor: ID3TagEditor(), openAction: openAction)
        self.id3TagWriter = ID3TagWriter(id3TagEditor: ID3TagEditor(), saveAction: saveAction)
        self.form = Form()
        self.saveResult = PublishSubject<Bool>()
        super.init()

        id3TagReader.read { [unowned self] id3Tag in
            self.form.fillFields(using: id3Tag)
        }
        
        id3TagWriter.write(input: Observable.combineLatest(form.readFields(), openAction)) { result in
            self.saveResult.onNext(result)
        }
    }
}
