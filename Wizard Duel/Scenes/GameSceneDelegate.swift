//
//  GameSceneDelegate.swift
//  Freegraveyard2
//
//  Created by gary on 01/09/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

protocol GameSceneDelegate: class {
    func newGame(currentGameState: Game.State, gameScene: GameScene) -> Bool
    
}
