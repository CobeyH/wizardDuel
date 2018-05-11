//
//  Cascade.swift
//  Freecell2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

final class Cascade: CanAddCard, ContainsCard {
    var cards: [Card]

    init() {
        self.cards = []
    }

    
    init(cards: [Card]) {
        self.cards = cards
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


    func contains(card: Card) -> Bool {
        for currentCard in cards {
            if card == currentCard {
                return true
            }
        }
        return false
    }


    func canAdd(card: Card) -> Bool {
        return true
    }


    func add(card: Card) throws {
        if canAdd(card: card) {
            cards.append(card)
        } else {
            throw GameError.invalidMove
        }
    }


    func reset(with cards: [Card]) {
        self.cards = cards
    }
}


extension Cascade: CustomDebugStringConvertible {
    var debugDescription: String {
        let cardDescriptions = cards.map({ $0.debugDescription }).joined(separator: " ")
        return "Cascade(\(cardDescriptions))"
    }
}
