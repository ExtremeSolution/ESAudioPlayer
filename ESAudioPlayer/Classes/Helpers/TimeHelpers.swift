//
//  TimeHelpers.swift
//  Anaphora
//
//  Created by Mario Mouris on 21/06/2021.
//

import Foundation

extension Double {
    func toMinutesAndSeconds() -> (Minutes, Seconds) {
        let (_,  minf) = modf(self / 3600)
        let (min, secf) = modf(60 * minf)
        return (Int(min), Int(60 * secf))
    }
}

func convertMinutesAndSecondsToTotalSeconds(
    minutes: Minutes,
    seconds: Seconds
) -> Seconds {
    return (minutes * 60) + seconds
}
