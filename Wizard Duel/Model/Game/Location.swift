//
//  Location.swift
//  Wizard duel
//
//  Created by gary on 19/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//
enum Location {
    case hand()
    case graveyard(Int)
    case deck()
    case battlefield(Int, Int)
    case dataExtract()
    case tokens()
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
        case .battlefield(let value1, let value2):
            return "battlefield(\(value1),\(value2)"
        case .dataExtract():
            return "dataExtract"
        case .tokens:
            return "tokens"
        }
    }
}
