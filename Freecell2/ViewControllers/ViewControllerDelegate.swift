//
//  ViewControllerDelegate.swift
//  Freecell2
//
//  Created by gary on 11/09/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

protocol ViewControllerDelegate: class {
    var gameState: Game.State { get }
    func newGame()
    func undo()
}
