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
        
        // sets of the two Graveyards to the right of the deck
        for i in 0 ..< config.graveyardCount {
            let graveyard = SKSpriteNode(color: config.backgroundColour, size: config.cardSize)
            graveyard.anchorPoint = config.cardMiddle
            graveyard.position = CGPoint(x: config.offsetX - config.margin + CGFloat(i + 1) * (config.cardSize.width + config.spacing), y: config.margin + config.offsetY)
            graveyard.zPosition = baseZPosition
            graveyards.append(graveyard)
        }
        
        // Sets up the hand at the bottom of the screen
            hands.color = config.backgroundColour
            hands.size = CGSize(width: config.cardSize.width * 5, height: config.cardSize.height)
            hands.anchorPoint = config.cardMiddle
            hands.position = CGPoint(x: -config.margin + 5 * config.offsetX, y: -config.margin - height + config.cardSize.height + config.offsetY)
            hands.zPosition = baseZPosition

        // Sets up the deck in the top left corner
            deck.color = config.backgroundColour
            deck.size = config.cardSize
            deck.anchorPoint = config.cardMiddle
            deck.position = CGPoint(x: -config.margin + config.offsetX, y: config.margin + config.offsetY)
            deck.zPosition = baseZPosition
       
        // Sets up all the labels for the deck count, graveyard count, etc.
        deckCount.fontSize = 40
        deckCount.fontColor = SKColor.black
        deckCount.position = CGPoint(x: -2 * config.margin, y: 2 * config.margin - config.cardSize.height)
        deckCount.zPosition = config.getZIndex()
        
        //Sets up all the graveyards in the arena
        for i in 0 ..< Int(width/config.cardSize.width - 1) {
            for j in 0 ..< Int(height/config.cardSize.height - 3) {
                let battlefieldCell = SKSpriteNode(color: config.battlefieldColour, size: config.cardSize)
                battlefieldCell.anchorPoint = config.cardMiddle
                battlefieldCell.position = CGPoint(x: -config.margin + config.offsetX + (config.cardSize.width + config.spacing/2) * CGFloat(i), y: -config.cardSize.height + config.margin - 2 * config.spacing - (config.cardSize.height + config.spacing/2) * CGFloat(j) + config.offsetY)
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
    

    //Adds all the sprite images to the deck to create a stack of cards
    mutating func setupCards(gameDecks: Deck) {
        
            let deckPosition = deck.position
            for (i, gameCard) in gameDecks.cards.enumerated() {
                let card = PlayingCard(card: gameCard, size: config.cardSize)
                card.anchorPoint = config.cardMiddle
                card.size = config.cardSize
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
        for battlefieldCell in battlefieldCells {
            scene.addChild(battlefieldCell)
        }
        scene.addChild(hands)
        scene.addChild(deck)
        scene.addChild(deckCount)
        scene.addChild(newGameButton)
        addCards(to: scene)
    }

    //Adds the cards sprites to the visual deck
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

    //Returns the playingcards found at a specific location and returns the one with the greatest z position
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
    
    //Rotates the card sideways if it is upright and turns it upright if it was sideways
    func tapCard(card: PlayingCard) {
        let playingCard = card
        if playingCard.tapped == false {
            playingCard.zRotation = CGFloat(Double.pi/2)
        }
        else {
            playingCard.zRotation = CGFloat(0)
        }
        card.tapped = card.tapped ? false : true
    }
    
    
    //Orders the cards properly when a card is removed from the middle of a cell
    mutating func updateCardStack(card: CurrentPlayingCard, gameBattleDeck: [Battlefield], hand: Hand) {
        let location = card.location
        let playingCards = cardsInCell(location: location, gameBattleDeck: gameBattleDeck , hand: hand)
        var i = 0
        switch location {
            case .battlefield(let value):
                
                let battlefield = battlefieldCells[value]
                for playingCard in playingCards {
                    setActive(card: playingCard)
                    let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: playingCard.anchorPoint, location: location)
                    let position =  CGPoint(x: battlefield.position.x + config.cardSize.width/2 - config.offsetX, y: battlefield.position.y - CGFloat(i) * config.battlefierdSpacing - config.cardSize.height/2 - config.offsetY)
                    currentPlayingCard.move(to: position)
                    i = i + 1
                }
            
            case .hand():
                for playingCard in playingCards {
                    setActive(card: playingCard)
                    let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: playingCard.anchorPoint, location: location)
                    let position =  CGPoint(x: -4 * config.offsetX + hands.position.x + CGFloat(i) * config.cardSize.width, y: hands.position.y)
                    currentPlayingCard.move(to: position)
                    i = i + 1
            }
            
            default: break
            
        }
    }
       
    //Returns all the cards at a specific lacation in sorted order based on zPosition
    private mutating func cardsInCell(location: Location, gameBattleDeck: [Battlefield], hand: Hand) -> [PlayingCard] {
        var playingCards : [PlayingCard] = []
        
            switch location {
    
            case .battlefield(let value):
            let battlefieldCards = gameBattleDeck[value]
                for card in cards {
                    if battlefieldCards.contains(card: card.card) {
                        playingCards.append(card)
                    }
                }
        
            case .hand():
                for card in cards {
                    if hand.contains(card: card.card) {
                        playingCards.append(card)
                    }
            }
            default: break
        }
        playingCards.sort(by: { $0.zPosition < $1.zPosition })
        return playingCards
    }
    
    //Moves the images of the card to reflect the arrangment in the model
    func move(currentPlayingCard: CurrentPlayingCard, to location: Location, gameDecks: Deck?, gameBattleDeck: [Battlefield]?, hand: Hand?) {
       let playingCard = currentPlayingCard.playingCard
        let newPosition: CGPoint
        switch location {
            
        case .graveyard(let value):
            let graveyard = graveyards[value]
            newPosition = graveyard.position
            playingCard.faceUp = true
            playingCard.heldBy = "Graveyard"
            
        case .hand():
            let cardCount = hand!.cards.count - 1
            newPosition = CGPoint(x: -4 * config.offsetX + hands.position.x + CGFloat(cardCount) * config.cardSize.width, y: hands.position.y)
            playingCard.faceUp = true
            playingCard.heldBy = "Hand"
            
        case .deck():
            let gameDeck = gameDecks
            let cardCount = gameDeck!.cards.count - 1
            let deckPosition = deck.position
            newPosition = CGPoint(x: deckPosition.x + CGFloat(cardCount)/4 - config.offsetX, y: deckPosition.y + CGFloat(cardCount)/4 - config.offsetY)
            playingCard.faceUp = false
            playingCard.heldBy = "Deck"
            
        case .battlefield(let value):
            let battlefield = battlefieldCells[value]
            let battleDeck = gameBattleDeck![value]
            let cardCount = battleDeck.cards.count - 1
            let deckPosition = battlefield.position
            newPosition = CGPoint(x: deckPosition.x + config.cardSize.width/2 - config.offsetX, y: deckPosition.y - CGFloat(cardCount) * config.battlefierdSpacing - config.cardSize.height/2 - config.offsetY)
            playingCard.faceUp = true
            playingCard.heldBy = "Battlefield"
        }
        
        updateLabels(gameDeck: gameDecks!)
        currentPlayingCard.move(to: newPosition)
    }
    

    //Returns the location at the point passed in
    func dropLocation(from position: CGPoint, playingCard: PlayingCard, game: Game) -> Location? {
        for (i, graveyard) in graveyards.enumerated() {
            if graveyard.contains(position) {
                return .graveyard(i)
            }
        }
        if hands.contains(position) {
            return .hand()
        }
        
        for playingCard in cards {
            if playingCard == playingCard { continue }
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

    // MARK: - Private
    
    
//    //Used in the undo method to determine the origonal location of the card
//    private func positionFrom(location: Location) -> CGPoint {
//        let position: CGPoint
//        switch location {
//        case .deck():
//            print("deck position")
//            position = deck.position
//        case .graveyard(let value):
//            let graveyard = graveyards[value]
//            print("graveyard position")
//            position = graveyard.position
//        case .hand():
//            print("hand position")
//            position = hands.position
//        case .battlefield(let value):
//            let battlefield = battlefieldCells[value]
//            print("battlefield position")
//            position = battlefield.position
//        }
//        return CGPoint(x: position.x + config.cardSize.width/2, y: position.y - config.cardSize.height/2)
//    }


    private func findPlayingCard(from card: Card) -> PlayingCard {
        for playingCard in cards {
            if playingCard.card == card {
                return playingCard
            }
        }
        fatalError("Couldn't find PlayingCard from Card")
    }
}
