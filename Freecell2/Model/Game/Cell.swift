//
//  Cell.swift
//  Freecell2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

final class Cell: CanAddCard, ContainsCard, HasState, Resetable {

    var state: State = .empty

    
    func canAdd(card: Card) -> Bool {
        switch state {
        case .empty:
            return true
        default:
            return false
        }
    }


    func add(card: Card) throws {
        if canAdd(card: card) {
            state = .card(card)
        } else {
            throw GameError.invalidMove
        }
    }


    func removeCard() {
        state = .empty
    }
}


extension Cell: CustomDebugStringConvertible {
    var debugDescription: String {
        switch state {
        case .empty:
            return ".."
        case .card(let card):
            return card.debugDescription
        }
    }
}
