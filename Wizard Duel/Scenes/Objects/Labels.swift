//
//  File.swift
//  Freecell2
//
//  Created by Cobey Hollier on 2018-05-19.
//  Copyright © 2018 Cobey Hollier. All rights reserved.
//

import SpriteKit

class Labels {
    var shuffleDeck: SKLabelNode = SKLabelNode(fontNamed: "Planewalker")
    var newTurnButton: SKLabelNode = SKLabelNode(fontNamed: "Planewalker")
    var cardDisplay: SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
    var mulliganButton: SKLabelNode?
    let keepButton: SKLabelNode = SKLabelNode(fontNamed: "Planewalker")
    let newGameButton: SKLabelNode = SKLabelNode(fontNamed: "Planewalker")
    var searchDeck: SKLabelNode?
    var xScale: CGFloat = 0
    var yScale: CGFloat = 0
    
    // Sets up all the labels for the deck count, graveyard count, etc.
    func setUpLabels(width: CGFloat, height: CGFloat, to scene: SKScene) {
        let scale = config.getScale()
        xScale = scale.0
        yScale = scale.1
        
        
        
        //New turn button
        newTurnButton.fontSize = 30
        cardDisplay.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        newTurnButton.color = SKColor.black
        newTurnButton.text = "New Turn"
        newTurnButton.position = CGPoint(x: width/2 + config.cardSize.width * 5, y: -height - config.margin + config.spacing * 4)
        newTurnButton.zPosition = 5
        newTurnButton.xScale = xScale
        newTurnButton.yScale = yScale
        scene.addChild(newTurnButton)
        
        //Adds buttons that have keyboard shortcuts on Mac OSX
        #if os(iOS)
        //New game button
        newGameButton.fontSize = 30
        newGameButton.color = SKColor.black
        newGameButton.text = "New Game"
        newGameButton.position = CGPoint(x: newTurnButton.position.x, y: newTurnButton.position.y + config.spacing * 4)
        newGameButton.zPosition = 5
        newGameButton.xScale = xScale
        newGameButton.yScale = yScale
        scene.addChild(newGameButton)
        
        searchDeck = SKLabelNode(fontNamed: "Planewalker")
        if let searchDeck = searchDeck {
            searchDeck.fontSize = 30
            searchDeck.color = SKColor.black
            searchDeck.text = "Import Deck"
            searchDeck.position = CGPoint(x: newTurnButton.position.x, y: newGameButton.position.y + config.spacing * 4)
            searchDeck.zPosition = 5
            searchDeck.xScale = xScale
            searchDeck.yScale = yScale
            scene.addChild(searchDeck)
        }
        #elseif os(OSX)
        //Shuffle Deck Dutton
        shuffleDeck.fontSize = 30
        shuffleDeck.color = SKColor.black
        shuffleDeck.text = "Shuffle"
        shuffleDeck.position = CGPoint(x: newTurnButton.position.x, y: newTurnButton.position.y - config.spacing * 4)
        shuffleDeck.zPosition = 5
        shuffleDeck.xScale = xScale
        shuffleDeck.yScale = yScale
        scene.addChild(shuffleDeck)
        #endif
    }
    
    func setupCardDisplay(width: CGFloat) {
        //cardDisplay Label
        cardDisplay.color = .clear
        cardDisplay.size = CGSize(width: config.cardSize.width * 2.5, height: config.cardSize.height * 2.5)
        cardDisplay.anchorPoint = CGPoint(x: 1, y: 1)
        cardDisplay.position = CGPoint(x: width, y: 0)
        cardDisplay.zPosition = 500
        
    }
    
    
    func isShuffleTapped(point: CGPoint) -> Bool {
        return shuffleDeck.contains(point)
    }
    
    func isNewTurnTapped(point: CGPoint) -> Bool {
        return newTurnButton.contains(point)
    }
    
    func isImportPressed(point: CGPoint) -> Bool {
        if let searchDeck = searchDeck {
            if searchDeck.contains(point) {
                return true
            }
        }
        return false
    }
    

    func setCardDisplay(playingCard: PlayingCard) {
        cardDisplay.texture = SKTexture(imageNamed: "\(playingCard.name!).full.jpg")
        
    }
    //Called at the start of the game to give the player the option to discard their hand and draw a new one.
    func addMulligan(to scene: SKScene) {
        mulliganButton = SKLabelNode(fontNamed: "Planewalker")
        mulliganButton!.fontSize = 30
        mulliganButton!.color = SKColor.black
        mulliganButton!.text = "Mulligan"
        mulliganButton!.position = CGPoint(x: scene.frame.width/5 - config.margin, y: -scene.frame.height + config.cardSize.height * 1.25)
        mulliganButton!.zPosition = 10
        mulliganButton!.xScale = xScale
        mulliganButton!.yScale = yScale
        scene.addChild(mulliganButton!)
        
        keepButton.fontSize = 30
        keepButton.color = SKColor.black
        keepButton.text = "Keep"
        keepButton.position = CGPoint(x: mulliganButton!.position.x + config.cardSize.height, y: mulliganButton!.position.y)
        keepButton.zPosition = 10
        keepButton.xScale = xScale
        keepButton.yScale = yScale
        scene.addChild(keepButton)
    }

    
    func removeButtons() {
        if mulliganButton != nil {
            mulliganButton!.removeFromParent()
            mulliganButton = nil
        }
        keepButton.removeFromParent()
        
    }
    
    
}
