//
//  Move.swift
//  Freecell2
//
//  Created by gary on 30/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

struct Move {
    let fromLocation: Location
    let toLocation: Location
}


extension Move: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Move(from: \(fromLocation), to: \(toLocation))"
    }
}
