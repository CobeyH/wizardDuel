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
    var deckCount: SKLabelNode = SKLabelNode(fontNamed: "planewalker")
    var cardDisplay: SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
    
    // Sets up all the labels for the deck count, graveyard count, etc.
    func setUpLabels(width: CGFloat, height: CGFloat, to scene: SKScene) {
        deckCount.text = "60"
        deckCount.fontSize = 40
        deckCount.fontColor = SKColor.black
        
        deckCount.position = CGPoint(x: -2 * config.margin, y: 2 * config.margin - config.cardSize.height)
        deckCount.zPosition = config.getZIndex()
        scene.addChild(deckCount)
        
        // New game button
        newGameButton.fontSize = 40
        newGameButton.color = SKColor.black
        newGameButton.text = "New Game"
        newGameButton.position = CGPoint(x: width / 2, y: -130)
        newGameButton.zPosition = 5
        scene.addChild(newGameButton)
        
        //cardDisplay Node
        cardDisplay.color = .clear
        cardDisplay.size = CGSize(width: config.cardSize.width * 2, height: config.cardSize.height * 2)
        cardDisplay.anchorPoint = CGPoint(x: 1, y: 1)
        cardDisplay.position = CGPoint(x: width, y: 0)
        cardDisplay.zPosition = config.getZIndex()
        scene.addChild(cardDisplay)
    }
    
    
    func isNewGameTapped(point: CGPoint) -> Bool {
        return newGameButton.contains(point)
    }
    
    func update(gameDeck: Deck) {
        deckCount.text = "\(gameDeck.cards.count)"
    }
    
    func setCardDisplay(playingCard: PlayingCard) {
        cardDisplay.texture = SKTexture(imageNamed: "\(playingCard.name!).full.jpg")
        
    }
    
    
    
}
