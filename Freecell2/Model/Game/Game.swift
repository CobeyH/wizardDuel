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
    
    private var moves = MoveHistory()

    
    
    // MARK: - Computed properties
    var isGameOver: Bool {
        return false
    }
    
    
    var state: State {
        if moves.noMovesMade {
            return .notStarted
        }
        return isGameOver ? .done : .playing
    }
    
    
    var lastMove: Move? {
        return moves.lastMove
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
        hands.reset()
//        for (deck, _) in zip(decks, deckConfig) {
           // deck.cards = Array(cards[config.0 ... config.1])
            deck.cards = cards
//        }
        moves.clear()
    }
    
    
    func canMove(card: Card) -> Bool {
        guard let location = location(from: card) else {
            return false
        }
        switch location {
        case .graveyard:
            return true
        case .hand:
            return true
        case .deck():
           return deck.isBottom(card: card)
        case .battlefield( _):
            return true

        }
    }
    
    func move(card currentPlayingCard: CurrentPlayingCard, to toLocation: Location) throws {
         let card = currentPlayingCard.playingCard.card
           
        try move(card: card, to: toLocation)
        let fromLocation = currentPlayingCard.location
        moves.add(move: Move(fromLocation: fromLocation, toLocation: toLocation))
        
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
    
    
//    func quickMove(from location: Location) throws -> Location {
//        switch location {
//        case .hand:
//            let newLocation = try moveToHand(from: location)
//            return newLocation
//        case .graveyard:
//            do {
//                let newLocation = try moveToHand(from: location)
//                return newLocation
//            }
//        case .deck:
//            do {
//                let newLocation = try moveToHand(from: location)
//                return newLocation
//            } catch {}
//            do {
//                let newLocation = try moveToGraveyard(from: location)
//                return newLocation
//            }
//        }
//    }
    
    
//    func moveToHand(from location: Location) throws -> Location {
//        guard let card = card(at: location) else {
//            throw GameError.invalidMove
//        }
//
//            switch hands.state {
//            case .empty:
//                    let newLocation = Location.hand()
//                    try move(from: location, to: newLocation)
//                    hands.state = .card(card)
//                    return newLocation
//
//            case .card( _):
//                throw GameError.invalidMove
//        }
//        return location
//    }
//
//
//    func moveToGraveyard(from location: Location) throws -> Location {
//        //        guard let _ = card(at: location) else {
//        //            throw GameError.invalidMove
//        //        }
//        for (i, _) in graveyards.enumerated() {
//
//                let newLocation = Location.graveyard(i)
//                try move(from: location, to: newLocation)
//            return newLocation
//        }
//        return location
//    }
    
    
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
    
    
    func undo(move: Move) -> Card? {
        print("game", undo)
        guard let card = card(at: move.toLocation) else { return nil }
        
        //        moves.undo()
        return card
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
