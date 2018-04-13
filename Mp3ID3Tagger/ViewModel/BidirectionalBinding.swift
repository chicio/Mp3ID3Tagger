//
//  BidirectionalBinding.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 13.04.18.
//

import Foundation
import RxSwift
import RxCocoa

infix operator <-> : DefaultPrecedence

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return CompositeDisposable(bindToUIDisposable, bindToVariable)
}
