//
//  MoveHistory.swift
//  Freecell2
//
//  Created by gary on 30/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

struct MoveHistory {
    private var moves: [Move] = []


    var lastMove: Move? {
        return moves.last
    }

    var noMovesMade: Bool {
        return moves.count == 0
    }

    
    mutating func add(move: Move) {
        moves.append(move)
    }


    mutating func undo() {
        let _ = moves.popLast()
    }


    mutating func clear() {
        moves = []
    }
}
