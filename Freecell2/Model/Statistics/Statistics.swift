//
//  Statistics.swift
//  Freecell2
//
//  Created by gary on 31/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

struct Statistics: Codable {
    var total: Total
    var streaks: Streaks

    init() {
        total = Total(won: 0, lost: 0)
        streaks = Streaks(total: Total(won: 0, lost: 0), state: .winning, current: 0)
    }


    mutating func update(with gameState: Game.State) {
        switch gameState {
        case .notStarted:
            return
        case .done:
            total.won += 1
        case .playing:
            total.lost += 1
        }
        streaks.update(with: gameState)
        print(self)
    }
}


extension Statistics: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Total: \(total), streaks: \(streaks)"
    }
}
