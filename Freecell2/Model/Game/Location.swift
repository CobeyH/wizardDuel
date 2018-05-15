//
//  Location.swift
//  Freehand2
//
//  Created by gary on 19/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

enum Location {
    case hand(Int)
    case graveyard(Int)
    case deck(Int)
    case battlefield(Int)
}


extension Location: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .hand(let value):
            return "hand(\(value))"
        case .graveyard(let value):
            return "graveyard(\(value))"
        case .deck(let value):
            return "deck(\(value))"
        case .battlefield(let value):
            return "battlefield(\(value))"
        }
    }
}
