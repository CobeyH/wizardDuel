//
//  Deck.swift
//  Freegraveyard2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

final class Deck: ContainsCard {
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

    func add(card: Card) throws {
            cards.append(card)
    }


    func reset(with cards: [Card]) {
        self.cards = cards
    }
}


extension Deck: CustomDebugStringConvertible {
    var debugDescription: String {
        let cardDescriptions = cards.map({ $0.debugDescription }).joined(separator: " ")
        return "Deck(\(cardDescriptions))"
    }
}
