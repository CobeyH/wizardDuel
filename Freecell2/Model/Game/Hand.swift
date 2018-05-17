//
//  Hand.swift
//  Freegraveyard2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

final class Hand: MasterDeck {
    
    
    
}



extension Hand: CustomDebugStringConvertible {
    var debugDescription: String {
        switch state {
        case .empty:
            return ".."
        case .card(let card):
            return card.debugDescription
        }
    }
}
    
    
   


