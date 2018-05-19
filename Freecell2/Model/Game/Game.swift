//
//  Game.swift
//  Freegraveyard2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

class Game {
    
    enum State {
        case notStarted
        case playing
        case done
    }
    
    // MARK: - Properties
    
    private let graveyards: [Graveyard]
    let hands: Hand
    let battlefieldCells: [Battlefield]
    let deck: Deck
    
    // MARK: - Computed properties
    var isGameOver: Bool {
        return false
    }
    
    var state: State {
        return isGameOver ? .done : .playing
    }
    
    
    // MARK: - Initialisers
    
    init() {
        graveyards = [Graveyard(), Graveyard()]
        hands = Hand()
        battlefieldCells = (0 ... 54).map({ _ in Battlefield() })
        deck = Deck()
        self.new()
    }
    
    // MARK: - Methods
    func new() {
        let cards = Card.deck().shuffled()
        graveyards.forEach({ $0.reset() })
        battlefieldCells.forEach({ $0.reset() })
        hands.reset()
        deck.cards = cards
    }
    
    
    func canMove(card: Card) -> Bool {
        guard let location = location(from: card) else {
            return false
        }
        switch location {
            case .deck():
            return deck.isBottom(card: card)
       
                default:  return true
        }
    }
    
    //Deletes the model card from an array and calls the move method to add the card to a new array.
    func move(card currentPlayingCard: CurrentPlayingCard, to toLocation: Location) throws {
         let card = currentPlayingCard.playingCard.card
           
        try move(card: card, to: toLocation)
        let fromLocation = currentPlayingCard.location
        
        
        switch fromLocation {
        case .deck():
            deck.removeBottom()
        case .graveyard(let value):
            let graveyard = graveyards[value]
            graveyard.removeBottom()
        case .hand():
            hands.removeCard(card: card)
            
        case .battlefield(let value):
            let battlefield = battlefieldCells[value]
            battlefield.removeCard(card: card)

        }
    }
    
    //Passes the card and location to the private move method
    func quickMove(card: Card, location: Location) {
        let toLocation = Location.hand()
        do {
        try move(card: card, to: toLocation)
        } catch {}
        
    }
    
    //returns the number of cards in a given array when passed a location.
    func countCards(location: Location) -> Int {
        switch location {
        case .hand():
            return hands.cards.count - 1
            
        case .deck():
            return deck.cards.count - 1
            
        case .graveyard(let value):
            let graveyard = graveyards[value]
            return graveyard.cards.count - 1
        case .battlefield(let value):
            let battlefield = battlefieldCells[value]
            return battlefield.cards.count - 1
        }
    }
    
    //Returns the location of a given card
    func location(from card: Card) -> Location? {
        for (i, graveyard) in graveyards.enumerated() {
            if graveyard.contains(card: card) {
                return Location.graveyard(i)
            }
        }
        
        if hands.contains(card: card) {
            return Location.hand()
        }
        
        
            if deck.contains(card: card) {
                return Location.deck()
            }
        
        for (i, battlefield) in battlefieldCells.enumerated() {
            if battlefield.contains(card: card) {
                return Location.battlefield(i)
            }
        }
        return nil
    }
    
    // MARK: - Private
    
    private func card(at location: Location) -> Card? {
        switch location {
        case .graveyard(let value):
            switch graveyards[value].state {
            case .empty: return nil
            case .card(let card): return card
            }
        case .hand():
            switch hands.state {
            case .empty: return nil
            case .card(let card): return card
            }
        case .deck():
            return deck.bottomCard
        case .battlefield(let value):
        return battlefieldCells[value].bottomCard
    }
    }
    
    //Implements the real adding of cards to the arrays in the model
    private func move(card: Card, to location: Location) throws {
        switch location {
        case .graveyard(let value):
            let graveyard = graveyards[value]
            try graveyard.add(card: card)
        case .hand():
            try hands.add(card: card)
        case .deck():
            try deck.add(card: card)
        case .battlefield(let value):
            let battlefield = battlefieldCells[value]
            try battlefield.add(card: card)
        }
        
    }
}


extension Game: CustomDebugStringConvertible {
    var debugDescription: String {
        let parts = [
            "Graveyards: \(graveyards)",
            "Hand: \(hands)",
        ]
        
        return parts.joined(separator: "\n")
    }
}
