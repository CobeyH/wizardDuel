//
//  GameGraphics.swift
//  Freegraveyard2
//
//  Created by gary on 31/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import SpriteKit

struct GameGraphics {

    private var config = GameGraphicsConfig()

    private var graveyards: [SKSpriteNode] = []
    private var hands: SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 75, height: 40))
    private var deck: SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 75, height: 40))
    private var battlefieldCells: [SKSpriteNode] = []
    private var newGameButton: SKLabelNode = SKLabelNode(fontNamed: "planewalker")
    private var deckCount = SKLabelNode(fontNamed: "planewalker")
    

    var cards: [PlayingCard] = []

    mutating func setup(width: CGFloat, height: CGFloat) {
        let baseZPosition: CGFloat = config.zIndexIncrement
        // Hand
        for i in 0 ..< config.graveyardCount {
            let graveyard = SKSpriteNode(color: config.backgroundColour, size: config.cardSize)
            graveyard.anchorPoint = config.topLeft
            graveyard.position = CGPoint(x: -config.margin + config.spacing + config.cardSize.width + CGFloat(i) * (config.cardSize.width + config.spacing), y: config.margin)
            graveyard.zPosition = baseZPosition
            graveyards.append(graveyard)
        }
        
        // Graveyards
        
            hands.color = config.backgroundColour
        hands.size = CGSize(width: config.cardSize.width * 5, height: config.cardSize.height)
            hands.anchorPoint = config.topLeft
//            hands.position = CGPoint(x: config.margin + config.cardSize.width * (config.cardSize.width + config.spacing/2), y: -config.margin - height + config.cardSize.height)
        hands.position = CGPoint(x: -config.margin, y: -config.margin - height + config.cardSize.height)
            hands.zPosition = baseZPosition
            
        

        // Decks
            deck.color = config.backgroundColour
            deck.size = config.cardSize
            deck.anchorPoint = config.topLeft
            deck.position = CGPoint(x: -config.margin, y: config.margin)
            deck.zPosition = baseZPosition
       
        // Labels
        deckCount.fontSize = 40
        deckCount.fontColor = SKColor.black
        deckCount.position = CGPoint(x: -2 * config.margin, y: 2 * config.margin - config.cardSize.height)
        deckCount.zPosition = config.getZIndex()
        
        //Battlefields
        for i in 0 ..< Int(width/config.cardSize.width - 1) {
            for j in 0 ..< Int(height/config.cardSize.height - 3) {
                let battlefieldCell = SKSpriteNode(color: config.battlefieldColour, size: config.cardSize)
                battlefieldCell.anchorPoint = config.topLeft
                battlefieldCell.position = CGPoint(x: -config.margin + (config.cardSize.width + config.spacing/2) * CGFloat(i), y: -config.cardSize.height + config.margin - 2 * config.spacing - (config.cardSize.height + config.spacing/2) * CGFloat(j))
                battlefieldCell.zPosition = baseZPosition
                battlefieldCells.append(battlefieldCell)
            }
        }
        // New game button
        newGameButton.fontSize = 40
        newGameButton.color = SKColor.black
        newGameButton.text = "New Game"
        newGameButton.position = CGPoint(x: width / 2, y: -130)
        newGameButton.zPosition = baseZPosition
    }
    


    mutating func setupCards(gameDecks: Deck) {
        // Playing cards
        
            let deckPosition = deck.position
            for (i, gameCard) in gameDecks.cards.enumerated() {
                let card = PlayingCard(card: gameCard, size: config.cardSize)
                card.anchorPoint = config.topLeft
                card.size = config.cardSize
               // card.position = CGPoint(x: deckPosition.x, y: deckPosition.y + config.margin * CGFloat(i))
                card.position = CGPoint(x: deckPosition.x + CGFloat(i/10), y: deckPosition.y + CGFloat(i/4))
                card.zPosition = config.getZIndex()
                cards.append(card)
            }
        
    }

    //Adds all the children to the scene
    func addChildren(to scene: SKScene) {
        for graveyard in graveyards {
            scene.addChild(graveyard)
        }

            scene.addChild(hands)
        
        
            scene.addChild(deck)
        
        scene.addChild(deckCount)
        
        for battlefieldCell in battlefieldCells {
            scene.addChild(battlefieldCell)
        }
        addCards(to: scene)
        scene.addChild(newGameButton)
    }

    //Creates the deck by adding all the cards to the deck
    func addCards(to scene: SKScene) {
        for card in cards {
            scene.addChild(card)
        }
    }
    
    //Creates the background and sets its image
    func setupBackground(to scene: SKScene) {
        let backgroundTexture = SKTexture(imageNamed: config.backgroundName)
        let background: SKSpriteNode = SKSpriteNode( color: .clear, size: CGSize(width: scene.size.width, height: scene.size.height))
        
        background.texture = backgroundTexture
        background.anchorPoint = CGPoint(x: 0, y: 1)
        background.zPosition = -5
        scene.addChild(background)
    }


    func cardFrom(position: CGPoint) -> PlayingCard? {
        var candidateCards: [PlayingCard] = []
        for card in cards {
            if card.contains(position) {
                candidateCards.append(card)
            }
        }
        candidateCards.sort(by: { $0.zPosition < $1.zPosition })
        return candidateCards.last
    }


    func isNewGameTapped(point: CGPoint) -> Bool {
        return newGameButton.contains(point)
    }


    mutating func setActive(card: PlayingCard) {
        card.zPosition = config.getZIndex()
    }


    mutating func newGame(gameDecks: Deck) {
        for card in cards {
            card.removeFromParent()
        }
        cards = []
        setupCards(gameDecks: gameDecks)
    }
    
    func tapCard(card: CurrentPlayingCard) {
        let playingCard = card.playingCard
        
        playingCard.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if playingCard.tapped == false {
            playingCard.zRotation = CGFloat(Double.pi/2)
            //let rotate:SKAction = SKAction.rotate(byAngle: CGFloat.pi / 2, duration: 2)
            //playingCard.run(rotate)
        }
        else {
            playingCard.zRotation = CGFloat(0)
        }

        card.playingCard.tapped = card.playingCard.tapped ? false : true
    }


    func move(currentPlayingCard: CurrentPlayingCard, to location: Location, gameDecks: Deck, gameBattleDeck: [Battlefield], hand: Hand) {
        let newPosition: CGPoint
        switch location {
            
        case .graveyard(let value):
            let graveyard = graveyards[value]
            newPosition = graveyard.position
            currentPlayingCard.playingCard.faceUp = true
            
        case .hand():
            let cardCount = hand.cards.count - 1
            newPosition = CGPoint(x: hands.position.x + CGFloat(cardCount) * config.cardSize.width, y: hands.position.y)
            currentPlayingCard.playingCard.faceUp = true
            
        case .deck():
            let gameDeck = gameDecks
            let cardCount = gameDeck.cards.count - 1
            let deckPosition = deck.position
            newPosition = CGPoint(x: deckPosition.x + CGFloat(cardCount)/4, y: deckPosition.y + CGFloat(cardCount)/4)
            currentPlayingCard.playingCard.faceUp = false
            
        case .battlefield(let value):
            let battlefield = battlefieldCells[value]
            let battleDeck = gameBattleDeck[value]
            let cardCount = battleDeck.cards.count - 1
            let deckPosition = battlefield.position
            newPosition = CGPoint(x: deckPosition.x, y: deckPosition.y - CGFloat(cardCount) * config.battlefierdSpacing)
            currentPlayingCard.playingCard.faceUp = true
        
        }
        updateLabels(gameDeck: gameDecks)
        currentPlayingCard.move(to: newPosition)
    }


    func dropLocation(from position: CGPoint, currentPlayingCard: CurrentPlayingCard, game: Game) -> Location? {
        for (i, graveyard) in graveyards.enumerated() {
            if graveyard.contains(position) {
                return .graveyard(i)
            }
        }
        if hands.contains(position) {
            return .hand()
        }
        
        for playingCard in cards {
            if playingCard == currentPlayingCard.playingCard { continue }
            if playingCard.contains(position) {
                if let location = game.location(from: playingCard.card) {
                    switch location {
                    case .deck():
                        let deck = game.deck
                        if deck.isBottom(card: playingCard.card) {
                            return location
                        }
                    default:
                        break
                    }
                }
            }
        }
        
            if deck.contains(position) {
                let gameDeck = game.deck
                if gameDeck.isEmpty {
                    return .deck()
                }
            }
        
        for (i, battlefield) in battlefieldCells.enumerated() {
            if battlefield.contains(position) {
                    return .battlefield(i)
            }
        }
        return nil
    }
    
    func updateLabels(gameDeck: Deck) {
        deckCount.text = "\(gameDeck.cards.count)"
    }


//    func undo(move: Move, card: Card, gameDecks: Deck, battleDecks: [battlefield]) {
//        print("game graphics, undo", move)
//        let position = positionFrom(location: move.toLocation)
//        print(position)
//        let playingCard = findPlayingCard(from: card)
//        let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: playingCard.position, location: move.toLocation)
//        // TODO
//        self.move(currentPlayingCard: currentPlayingCard, to: move.fromLocation, gameDecks: gameDecks, gameBattleDeck: battleDecks)
//
//    }


    // MARK: - Private
    
    
    //Used in the undo method to determine the origonal location of the card
    private func positionFrom(location: Location) -> CGPoint {
        let position: CGPoint
        switch location {
        case .deck():
            print("deck position")
            position = deck.position
        case .graveyard(let value):
            let graveyard = graveyards[value]
            print("graveyard position")
            position = graveyard.position
        case .hand():
            print("hand position")
            position = hands.position
        case .battlefield(let value):
            let battlefield = battlefieldCells[value]
            print("battlefield position")
            position = battlefield.position
        }
        return CGPoint(x: position.x + config.cardSize.width/2, y: position.y - config.cardSize.height/2)
    }


    private func findPlayingCard(from card: Card) -> PlayingCard {
        for playingCard in cards {
            if playingCard.card == card {
                return playingCard
            }
        }
        fatalError("Couldn't find PlayingCard from Card")
    }
}
