//
//  Graveyard.swift
//  Freegraveyard2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

final class Graveyard: CanAddCard, ContainsCard, HasState, Resetable {

    var state: State = .empty
    var isDone: Bool {
        return false
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
    
    
    func removeCard() {
        state = .empty
    }
}

