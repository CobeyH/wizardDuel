//
//  Foundation.swift
//  Freecell2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

final class Foundation: CanAddCard, ContainsCard, HasState, Resetable {

    var state: State = .empty

    var isEmpty: Bool {
        switch state {
        case .empty: return true
        default: return false
        }
    }


    func canAdd(card: Card) -> Bool {
            return true
    }


    func add(card: Card) throws {
        if canAdd(card: card) {
            state = .card(card)
        } else {
            throw GameError.invalidMove
        }
    }


    var isDone: Bool {
            return false
        }
    }



extension Foundation: CustomDebugStringConvertible {
    var debugDescription: String {
        switch state {
        case .empty:
            return ".."
        case .card(let card):
            return card.debugDescription
        }
    }
}
