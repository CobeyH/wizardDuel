//
//  Deck.swift
//  Freegraveyard2
//
//  Created by Cobey on 13/05/2018.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

final class Battlefield: MasterDeck {
    
}
    
    
    
extension Battlefield: CustomDebugStringConvertible {
    var debugDescription: String {
        let cardDescriptions = cards.map({ $0.debugDescription }).joined(separator: " ")
        return "Battlefield(\(cardDescriptions))"
    }
}

