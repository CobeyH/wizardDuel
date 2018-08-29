//
//  Game.swift
//  Freegraveyard2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//
import Foundation
class Game {
    
    enum State {
        case notStarted
        case playing
        case done
        case viewingTokens
    }
    
    // MARK: - Properties
    private let graveyards: [Graveyard]
    let hands: Hand
    var allBattlefields: [[Battlefield]] = [[],[],[],[]]
    let deck: Deck
    let dataExtract: MasterDeck
    var commander: String
    var deckURL: URL?
    var tokens: Deck
    
    // MARK: - Computed properties
    var isGameOver: Bool {
        return false
    }
    
    var state: State {
        return isGameOver ? .done : .playing
    }
    
    
    // MARK: - Initialisers
    init() {
        graveyards = [Graveyard(), Graveyard(), Graveyard()]
        hands = Hand()
        dataExtract = MasterDeck()
        
        for i in 0...3 {
            allBattlefields[i] = (0 ... 50).map({ _ in Battlefield() })
        }
        deck = Deck()
        commander = "none"
        tokens = Deck()
    }
    
    // MARK: - Methods
    func new() {
        if deckURL == nil {
            deckURL = Card.pickDeck()
        }
        let rawData = Card.cardsFromFile(url: deckURL)
        let deckTouple = Card.parseDeck(strings: rawData)
        newDeck(deckTouple: deckTouple)
        
    }

    func newDeck(deckTouple: ([Card],String)) {
        let cards = deckTouple.0.shuffled()
        commander = deckTouple.1
        graveyards.forEach({ $0.cards = [] })
        for i in 0...3 {
            allBattlefields[i].forEach({ $0.cards = [] })
        }
        hands.cards = []
        deck.cards = cards
    }
    
    
    func canMove(card: Card) -> Bool {
        guard let location = location(from: card) else {
            return false
        }
        switch location {
            case .deck():
            return true
       
        default: return true
        }
    }
    
    //Deletes the model card from an array and calls the move method to add the card to a new array.
    func move(card currentPlayingCard: CurrentPlayingCard, to toLocation: Location) throws {
         let card = currentPlayingCard.playingCard.card
           
        try move(card: card, to: toLocation)
        let fromLocation = currentPlayingCard.location
        
        
        switch fromLocation {
        case .deck():
            deck.removeCard(card: card)
        case .graveyard(let value):
            let graveyard = graveyards[value]
            graveyard.removeBottom()
        case .hand():
            hands.removeCard(card: card)
        case .battlefield(let field, let stack):
            let battlefield = allBattlefields[field]
            let stack = battlefield[stack]
            stack.removeCard(card: card)
        case .dataExtract():
            dataExtract.removeBottom()
        case .tokens():
            tokens.removeCard(card: card)
        }
    }
    
    //Passes the card and location to the private move method
    func quickMove(card: Card, location: Location) {
        let toLocation = Location.hand()
        do {
        try move(card: card, to: toLocation)
        } catch {}
        
    }
    
    func createTokens() -> [Card] {
        let URL = Bundle.main.url(forResource: "tokens", withExtension: "txt")
        let rawData = Card.cardsFromFile(url: URL)
        let addedTokens = Card.parseDeck(strings: rawData)
        for token in addedTokens.0 {
            
                do {
                  try  tokens.add(card: token)
                } catch {
                print("failed to add token to game")
            }
        }
        
        return addedTokens.0
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
        case .battlefield(let field, let stack):
            let battlefield = allBattlefields[field]
            let stack = battlefield[stack]
            return stack.cards.count - 1
    default: return 0
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
        
        for (i,battlefield) in allBattlefields.enumerated() {
            for (j,stack) in battlefield.enumerated() {
                if stack.contains(card: card) {
                    return Location.battlefield(i,j)
                }
            }
        }
        if tokens.contains(card: card) {
            return Location.tokens()
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
        case .battlefield(let field, let stack):
            let battlefield = allBattlefields[field]
        return battlefield[stack].bottomCard
        default: return nil
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
        case .battlefield(let field, let stack):
            let battlefield = allBattlefields[field]
            let stack = battlefield[stack]
            try stack.add(card: card)
        case .dataExtract():
            try dataExtract.add(card: card)
            case .tokens():
            try tokens.add(card: card)
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
