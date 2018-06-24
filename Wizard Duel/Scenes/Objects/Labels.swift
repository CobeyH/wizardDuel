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
    
    var shuffleDeck: SKLabelNode = SKLabelNode(fontNamed: "planewalker")
    var newTurnButton: SKLabelNode = SKLabelNode(fontNamed: "planewalker")
    var cardDisplay: SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
    let mulliganButton = SKLabelNode(fontNamed: "planewalker")
    let keepButton = SKLabelNode(fontNamed: "planewalker")
    // Sets up all the labels for the deck count, graveyard count, etc.
    func setUpLabels(width: CGFloat, height: CGFloat, to scene: SKScene) {
       
        
       
        
        //cardDisplay Label
        cardDisplay.color = .clear
        cardDisplay.size = CGSize(width: config.cardSize.width * 2.5, height: config.cardSize.height * 2.5)
        cardDisplay.anchorPoint = CGPoint(x: 1, y: 1)
        cardDisplay.position = CGPoint(x: width - cardDisplay.size.width/2, y: -cardDisplay.size.height/2)
        cardDisplay.zPosition = config.getZIndex()
        scene.addChild(cardDisplay)
        
        //New turn button
        newTurnButton.fontSize = 30
        cardDisplay.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        newTurnButton.color = SKColor.black
        newTurnButton.text = "New Turn"
        newTurnButton.position = CGPoint(x: width/2 + config.cardSize.width * 5, y: -height - config.margin + 50)
        newTurnButton.zPosition = 5
        scene.addChild(newTurnButton)
        
        //Shuffle Dek Dutton
        shuffleDeck.fontSize = 30
        shuffleDeck.color = SKColor.black
        shuffleDeck.text = "Shuffle"
        shuffleDeck.position = CGPoint(x: newTurnButton.position.x, y: newTurnButton.position.y - 50)
        shuffleDeck.zPosition = 5
        scene.addChild(shuffleDeck)
    }
    
    
    func isShuffleTapped(point: CGPoint) -> Bool {
        return shuffleDeck.contains(point)
    }
    
    func isNewTurnTapped(point: CGPoint) -> Bool {
        return newTurnButton.contains(point)
    }
    
    
    
    func setCardDisplay(playingCard: PlayingCard) {
        cardDisplay.texture = SKTexture(imageNamed: "\(playingCard.name!).full.jpg")
        
    }
    
    func addMulligan(to scene: SKScene) {
        mulliganButton.fontSize = 30
        mulliganButton.color = SKColor.black
        mulliganButton.text = "Mulligan"
        mulliganButton.position = CGPoint(x: scene.frame.width/5 - config.margin, y: -scene.frame.height + config.cardSize.height * 1.25)
        mulliganButton.zPosition = 10
        scene.addChild(mulliganButton)
        
        keepButton.fontSize = 30
        keepButton.color = SKColor.black
        keepButton.text = "Keep"
        keepButton.position = CGPoint(x: mulliganButton.position.x + config.cardSize.height, y: mulliganButton.position.y)
        keepButton.zPosition = 10
        scene.addChild(keepButton)
    }
    
    func handKept() {
        mulliganButton.removeFromParent()
        keepButton.removeFromParent()
    }
    
    
}
