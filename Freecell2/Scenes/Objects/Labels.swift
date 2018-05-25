//
//  File.swift
//  Freecell2
//
//  Created by Cobey Hollier on 2018-05-19.
//  Copyright © 2018 Gary Kerr. All rights reserved.
//

import SpriteKit

class Labels {
    private var config = GameGraphicsConfig()
    
    var newGameButton: SKLabelNode = SKLabelNode(fontNamed: "planewalker")
    var newTurnButton: SKLabelNode = SKLabelNode(fontNamed: "planewalker")
    var cardDisplay: SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
    // Sets up all the labels for the deck count, graveyard count, etc.
    func setUpLabels(width: CGFloat, height: CGFloat, to scene: SKScene) {
       
        
        // New game button
        newGameButton.fontSize = 40
        newGameButton.color = SKColor.black
        newGameButton.text = "New Game"
        newGameButton.position = CGPoint(x: width / 2, y: -130)
        newGameButton.zPosition = 5
        scene.addChild(newGameButton)
        
        //cardDisplay Label
        cardDisplay.color = .clear
        cardDisplay.size = CGSize(width: config.cardSize.width * 2, height: config.cardSize.height * 2)
        cardDisplay.anchorPoint = CGPoint(x: 1, y: 1)
        cardDisplay.position = CGPoint(x: width - config.cardSize.width, y: -config.cardSize.height)
        cardDisplay.zPosition = config.getZIndex()
        scene.addChild(cardDisplay)
        
        //New turn button
        newTurnButton.fontSize = 30
        cardDisplay.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        newTurnButton.color = SKColor.black
        newTurnButton.text = "New Turn"
        newTurnButton.position = CGPoint(x: width/2 + config.cardSize.width * 5, y: -height - config.margin)
        newTurnButton.zPosition = 5
        scene.addChild(newTurnButton)
    }
    
    
    func isNewGameTapped(point: CGPoint) -> Bool {
        return newGameButton.contains(point)
    }
    
    func isNewTurnTapped(point: CGPoint) -> Bool {
        return newTurnButton.contains(point)
    }
    
    
    
    func setCardDisplay(playingCard: PlayingCard) {
        cardDisplay.texture = SKTexture(imageNamed: "\(playingCard.name!).full.jpg")
        
    }
    
    
    
}
