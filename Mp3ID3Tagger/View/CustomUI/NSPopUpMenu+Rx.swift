//
//  NSPopUpMenu+Rx.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 13.04.18.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: NSPopUpButton {
    public var selectedItemTag: ControlProperty<Int?> {
        return base.rx.controlProperty(
            getter: { control in
                return control.selectedItem?.tag
            },
            setter: { control, tag in
                if let validTag = tag {
                    control.tag = validTag
                    control.selectItem(withTag: validTag)
                }
            }
        )
    }
}
