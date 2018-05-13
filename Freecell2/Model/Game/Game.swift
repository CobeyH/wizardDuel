//
//  Game.swift
//  Freecell2
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
    
    private let cells: [Cell]
    private let foundations: [Foundation]
    let cascades: [Cascade]
    
    private var moves = MoveHistory()
    private let cascadeConfig: [(Int, Int)] = [(0, 60), (7, 13), (14, 20), (21, 27), (28, 33), (34, 39), (40, 45), (46, 51)]
    
    
    // MARK: - Computed properties
    
    var isGameOver: Bool {
        return foundations.map({ $0.isDone }).reduce(true, { $0 && $1 })
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
        cells = [Cell(), Cell(), Cell()]
        foundations = [Foundation(), Foundation(), Foundation(), Foundation(), Foundation(), Foundation(), Foundation()]
        cascades = (0 ... 1).map({ _ in Cascade() })
        self.new()
    }
    
    
    // MARK: - Methods
    
    func new() {
        let cards = Card.deck().shuffled()
        cells.forEach({ $0.reset() })
        foundations.forEach({ $0.reset() })
        for (cascade, config) in zip(cascades, cascadeConfig) {
           // cascade.cards = Array(cards[config.0 ... config.1])
            cascade.cards = cards
        }
        moves.clear()
    }
    
    
    func canMove(card: Card) -> Bool {
//        guard let location = location(from: card) else {
//            return false
//        }
//        switch location {
//        case .cell:
//            return true
//        case .foundation:
//            return true
//        case .cascade(let value):
//            let cascade = cascades[value]
//           return cascade.isBottom(card: card)
//
//    }
        return true
    }
    
    func move(from fromLocation: Location, to toLocation: Location) throws {
        guard let card = card(at: fromLocation) else {
            throw GameError.invalidMove
        }
        try move(card: card, to: toLocation)
        
        moves.add(move: Move(fromLocation: fromLocation, toLocation: toLocation))
        
        switch fromLocation {
        case .cascade(let value):
            let cascade = cascades[value]
            cascade.removeBottom()
        case .cell(let value):
            let cell = cells[value]
            cell.removeCard()
        case .foundation:
            // can't remove card from here
            break
        }
    }
    
    
    func quickMove(from location: Location) throws -> Location {
        switch location {
        case .foundation:
            let newLocation = try moveToFoundation(from: location)
            return newLocation
        case .cell:
            do {
                let newLocation = try moveToFoundation(from: location)
                return newLocation
            }
        case .cascade:
            do {
                let newLocation = try moveToFoundation(from: location)
                return newLocation
            } catch {}
            do {
                let newLocation = try moveToCell(from: location)
                return newLocation
            }
        }
    }
    
    
    func moveToFoundation(from location: Location) throws -> Location {
        guard let card = card(at: location) else {
            throw GameError.invalidMove
        }
        for (i, foundation) in foundations.enumerated() {
            switch foundation.state {
            case .empty:
                    let newLocation = Location.foundation(i)
                    try move(from: location, to: newLocation)
                    foundation.state = .card(card)
                    return newLocation
                
            case .card( _):
                throw GameError.invalidMove
            }
        }
        return location
    }


//    func moveToFoundation(from location: Location) throws -> Location {
//        for (i, foundation) in foundations.enumerated() {
//            let newLocation = Location.foundation(i)
//            try move(from: location, to: newLocation)
//            return newLocation
//        }
//
//        return Location.foundation(0)
//    }
    
    
    func moveToCell(from location: Location) throws -> Location {
        //        guard let _ = card(at: location) else {
        //            throw GameError.invalidMove
        //        }
        for (i, cell) in cells.enumerated() {
    
                let newLocation = Location.cell(i)
                try move(from: location, to: newLocation)
            return newLocation
        }
        return location
    }
    
    
    func location(from card: Card) -> Location? {
        for (i, cell) in cells.enumerated() {
            if cell.contains(card: card) {
                return Location.cell(i)
            }
        }
        for (i, foundation) in foundations.enumerated() {
            if foundation.contains(card: card) {
                return Location.foundation(i)
            }
        }
        for (i, cascade) in cascades.enumerated() {
            if cascade.contains(card: card) {
                return Location.cascade(i)
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
        case .cell(let value):
            switch cells[value].state {
            case .empty: return nil
            case .card(let card): return card
            }
        case .foundation(let value):
            switch foundations[value].state {
            case .empty: return nil
            case .card(let card): return card
            }
        case .cascade(let value):
            return cascades[value].bottomCard
        }
    }
    
    
    private func move(card: Card, to location: Location) throws {
        switch location {
        case .cell(let value):
            let cell = cells[value]
            try cell.add(card: card)
        case .foundation(let value):
            let foundation = foundations[value]
            try foundation.add(card: card)
        case .cascade(let value):
            let cascade = cascades[value]
            try cascade.add(card: card)
        }
        
    }
}


extension Game: CustomDebugStringConvertible {
    var debugDescription: String {
        let parts = [
            "Cells: \(cells)",
            "Foundations: \(foundations)",
            cascades.map({ "\($0)" }).joined(separator: "\n")
        ]
        
        return parts.joined(separator: "\n")
    }
}
