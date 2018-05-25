//
//  MasterDeck.swift
//  Freecell2
//
//  Created by Cobey Hollier on 2018-05-16.
//  Copyright © 2018 Gary Kerr. All rights reserved.
//

import Foundation
class MasterDeck: ContainsCard, HasState, Resetable {
    
    var cards: [Card]
    var state: State = .empty
    
    init() {
        self.cards = []
    }
    
    var bottomCard: Card? {
        return cards.last
    }
    
    var isEmpty: Bool {
        return cards.isEmpty
    }
    
    
    func removeBottom() {
        let _ = cards.popLast()
    }
    
    
    func isBottom(card: Card) -> Bool {
        guard let bottomCard = cards.last else {
            return false
        }
        return card == bottomCard
    }
    
    func removeCard(card: Card) {
        cards.remove(at: cards.index(of: card)!)
    }
    
    
    func contains(card: Card) -> Bool {
        for currentCard in cards {
            if card == currentCard {
                return true
            }
        }
        return false
    }
    
    func add(card: Card) throws {
        cards.append(card)
        state = .card(card)
        
    }
    
    
    func reset(with cards: [Card]) {
        self.cards = cards
    }
}
