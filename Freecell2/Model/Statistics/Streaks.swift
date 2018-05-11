//
//  Streaks.swift
//  Freecell2
//
//  Created by gary on 31/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

struct Streaks: Codable {
    var total: Total
    var state: StreakState
    var current: Int


    mutating func update(with gameState: Game.State) {
        let oldState = state
        switch (state, gameState) {
        case (.winning, .done):
            current += 1
        case (.winning, .playing):
            current = 1
            state = .losing
        case (.losing, .done):
            current = 1
            state = .winning
        case (.losing, .playing):
            current += 1
        case (.winning, .notStarted), (.losing, .notStarted):
            break
        }
        updateTotal(streakState: oldState, gameState: gameState)
    }


    private mutating func updateTotal(streakState: StreakState, gameState: Game.State) {
        switch (streakState, gameState) {
        case (.winning, .done), (.losing, .done):
            if current > total.won {
                total.won = current
            }
        case (.winning, .playing), (.losing, .playing):
            if current > total.lost {
                total.lost = current
            }
        case (.winning, .notStarted), (.losing, .notStarted):
            break
        }
    }


    private mutating func updateTotal() {
        switch state {
        case .winning:
            if current > total.won {
                total.won = current
            }
        case .losing:
            if current > total.lost {
                total.lost = current
            }
        }
    }
}


extension Streaks: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Streak \(state): \(current), totals: \(total)"
    }
}
