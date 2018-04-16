//
//  TrackPositionInSetFields.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 14.04.18.
//

import Foundation
import ID3TagEditor
import RxSwift

class TrackPositionInSetFields {
    let trackPosition: Variable<String?>
    let totalTracks: Variable<String?>
    let trackPositionInSet: Observable<TrackPositionInSet?>
    
    init() {
        self.trackPosition = Variable<String?>(nil)
        self.totalTracks = Variable<String?>(nil)
        self.trackPositionInSet = Observable.combineLatest(
            trackPosition.asObservable(),
            totalTracks.asObservable()
        ) { (trackPosition, totalTracks) -> TrackPositionInSet? in
            if let validTrackPositionAsString = trackPosition,
                let validTrackPosition = Int(validTrackPositionAsString) {
                return TrackPositionInSet(position: validTrackPosition, totalTracks: Int(totalTracks ?? ""))
            }
            return nil
        }
    }
}
