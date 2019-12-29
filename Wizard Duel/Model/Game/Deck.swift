//
//  Deck.swift
//  Wizard Duel
//
//  Created by Cobey Hollier.
//

final class Deck: ContainsCard {
    var cards: [Card]

    init() {
        self.cards = []
    }

    
    init(cards: [Card]) {
        self.cards = cards
    }

    //Returns the model card that is on the top of the pile (the only valid card to move)
    var bottomCard: Card? {
        return cards.last
    }

    
    var isEmpty: Bool {
        return cards.isEmpty
    }

    //Removes the model card that is on the top of the pile
    func removeBottom() {
        let _ = cards.popLast()
    }
    
    func removeCard(card: Card) {
        if let index = cards.index(of: card) {
            cards.remove(at: index)
        }
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

    //Adds a card to the model. This is a name which is stored in an array inside each cell.
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
