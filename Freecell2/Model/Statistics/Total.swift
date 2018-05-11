//
//  Total.swift
//  Freecell2
//
//  Created by gary on 31/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

struct Total: Codable {
    var won: Int
    var lost: Int
}


extension Total: CustomDebugStringConvertible {
    var debugDescription: String {
        return "won: \(won), lost: \(lost)"
    }
}
