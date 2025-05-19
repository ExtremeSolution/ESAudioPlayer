//
//  TimeHelpers.swift
//  Anaphora
//
//  Created by Mario Mouris on 21/06/2021.
//

import Foundation

extension Double {
    func toMinutesAndSeconds() -> (minutes: Int, seconds: Int) {
        guard self.isFinite, !self.isNaN, self >= 0 else { return (0, 0) }

        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return (minutes, remainingSeconds)
    }
}

func convertMinutesAndSecondsToTotalSeconds(
    minutes: Minutes,
    seconds: Seconds
) -> Seconds {
    return (minutes * 60) + seconds
}
