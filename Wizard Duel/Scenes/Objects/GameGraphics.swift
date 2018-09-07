//
//  GameGraphics.swift
//
//  Created by gary on 31/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import SpriteKit
#if os(iOS)
import Firebase
#elseif os(OSX)
import FirebaseDatabase
#endif

struct GameGraphics {
    //MARK: - Initalizers
    private var labels = Labels()
    private var graveyards: [SKSpriteNode] = []
    var hands: SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 75, height: 40))
    var deck: SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 75, height: 40))
    var allBattlefields: [[SKSpriteNode]] = [[], [], [], []]
    private var deckCount: SKLabelNode = SKLabelNode(fontNamed: "planewalker")
    private var diceSpawner: SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 75, height: 40))
    private var background: SKSpriteNode = SKSpriteNode(color: .clear, size: CGSize(width: 75, height: 40))
    
    var cards: [PlayingCard] = []
    private var dices: [PlayingDice] = []
    private var playerInfos: [PlayerInfo] = []
    
    //MARK: - Setup Methods
    //Sets up most of the background items such as the grey cells for cards.
    mutating func setup(width: CGFloat, height: CGFloat) {
        let baseZPosition: CGFloat = config.zIndexIncrement
        labels.setupCardDisplay(width: width)
        
        
        // Sets up the hand at the bottom of the screen
        hands.color = config.backgroundColour
        hands.size = CGSize(width: config.cardSize.width * 7, height: config.cardSize.height)
        hands.anchorPoint = config.cardMiddle
        hands.position = CGPoint(x: config.spacing + 7 * config.offsetX, y: -height + config.cardSize.height + config.offsetY)
        hands.zPosition = baseZPosition
        
        // Sets up the deck in bottom right corner
        deck.color = config.backgroundColour
        deck.size = config.cardSize
        deck.anchorPoint = config.cardMiddle
        deck.position = CGPoint(x: hands.size.width + config.cardSize.width + config.offsetX, y: -config.offsetY - height)
        deck.zPosition = baseZPosition
        
        //Sets up the counter for the deck
        deckCount.text = String(cards.count)
        deckCount.fontSize = 40
        deckCount.fontColor = SKColor.white
        deckCount.zPosition = config.getZIndex()
        deckCount.position = CGPoint(x: deck.position.x, y: deck.position.y + config.cardSize.height + config.offsetY + 1.5 * config.spacing)
        
        // sets of the two Graveyards to the right of the deck
        for i in 0 ..< config.graveyardCount {
            let graveyard = SKSpriteNode(color: config.backgroundColour, size: config.cardSize)
            graveyard.anchorPoint = config.cardMiddle
            graveyard.position = CGPoint(x: deck.position.x + CGFloat(i + 1) * (config.cardSize.width + 10), y: deck.position.y)
            graveyard.zPosition = baseZPosition
            graveyards.append(graveyard)
        }
        
        //Creates an offscreen field where cards are placed and moved into the battlefield
        let dataExtract = SKSpriteNode(color: config.backgroundColour, size: config.cardSize)
        dataExtract.anchorPoint = config.cardMiddle
        dataExtract.position = CGPoint(x: -100, y: 100)
        dataExtract.zPosition = baseZPosition
        
        //Sets up the spawner for the dice.
        diceSpawner.size = config.diceSizeFinal
        diceSpawner.texture = SKTexture(imageNamed: "dice1")
        diceSpawner.position = CGPoint(x: graveyards[2].position.x + config.cardSize.width/2 + config.diceSizeFinal.width/2 , y: -height + diceSpawner.size.height/2)
        diceSpawner.anchorPoint = CGPoint(x:0.5, y:0.5)
        
        //Sets up all the battlefields in the arena
        let startPositions: [CGPoint] = [CGPoint(x: 0, y: -height/2 - config.offsetY), CGPoint(x: 0, y: 0), CGPoint(x: width - 8*(config.cardSize.width + config.battlefieldSpacing), y: 0), CGPoint(x: width - 8*(config.cardSize.width + config.battlefieldSpacing), y: -height/2 - config.offsetY)]
        for k in 0 ..< 4 {
            for i in 0 ..< 8 {
                for j in 0 ..< 3 {
                    let battlefieldCell = SKSpriteNode(color: config.battlefieldColour, size: config.cardSize)
                    battlefieldCell.anchorPoint = config.cardMiddle
                    battlefieldCell.position = CGPoint(x: startPositions[k].x + config.offsetX + (config.cardSize.width + config.battlefieldSpacing) * CGFloat(i), y: -(config.cardSize.height + config.battlefieldSpacing) * CGFloat(j) + startPositions[k].y - config.cardSize.height/2)
                    battlefieldCell.zPosition = baseZPosition
                    allBattlefields[k].append(battlefieldCell)
                }
            }
        }
        
    }
    
    
    //Adds all the sprite images of the cards to the deck to create a stack of cards
    mutating func setupCards(gameDecks: Deck) {
        
        let deckPosition = deck.position
        for (i, gameCard) in gameDecks.cards.enumerated() {
            let card = PlayingCard(card: gameCard, size: config.cardSize, databaseRef: nil)
            card.anchorPoint = config.cardMiddle
            card.size = config.cardSize
            card.position = CGPoint(x: deckPosition.x , y: deckPosition.y + CGFloat(i/4))
            card.zPosition = config.getZIndex()
            cards.append(card)
        }
    }
    
    
    //Adds all the children to the scene
    func addChildren(to scene: SKScene) {
        for graveyard in graveyards {
            scene.addChild(graveyard)
        }
        for battlefieldArray in allBattlefields {
            for battlefieldCell in battlefieldArray {
                scene.addChild(battlefieldCell)
            }
        }
        scene.addChild(diceSpawner)
        scene.addChild(hands)
        scene.addChild(deck)
        scene.addChild(deckCount)
        scene.addChild(labels.cardDisplay)
        addCards(to: scene)
    }
    
    //Adds the cards to the scene.
    func addCards(to scene: SKScene) {
        for card in cards {
            scene.addChild(card)
        }
    }
    
    //Creates the background and sets its image
    func setupBackground(to scene: SKScene) {
        background.size = CGSize(width: scene.size.width, height: scene.size.height)
        background.texture = SKTexture(imageNamed: config.backgroundName)
        background.anchorPoint = CGPoint(x: 0, y: 1)
        background.zPosition = -5
        scene.addChild(background)
    }
    
    mutating func changeBackground(on scene: SKScene) {
        background.texture = SKTexture(imageNamed: config.getBackground())
    }
    
    //MARK: - Dice
    //Creates a new dice at the dice spawner.
    mutating func newDice(to scene: SKScene) -> PlayingDice {
        let dice = Dice(maxValue: 6)
        let playingDice = PlayingDice(dice: dice, size: config.diceSizeInitial)
        playingDice.zPosition = config.getZIndex()
        scene.addChild(playingDice)
        dices.append(playingDice)
        playingDice.update(position: diceSpawner.position)
        return playingDice
    }
    
    //Deletes a dice from the battlefield.
    mutating func deleteDice(to scene: SKScene, toDelete: PlayingDice) {
        for dice in dices {
           if dice == toDelete {
            dice.removeFromParent()
            dices.remove(at: dices.index(of: toDelete)!)
            }
        }
    }
    
    //Checks if a dice has been clicked.
    func isDiceTapped(point: CGPoint) -> Bool{
        if diceSpawner.contains(point) {
            return true
        }
        else { return false}
    }
    
    //Returns the dice at a position.
    func findDice(point: CGPoint) -> PlayingDice? {
        for dice in dices {
            if dice.contains(point) {
                return dice
            }
        }
        return nil
    }
    
    //Returns the dice that is the child of a card.
    func findDiceFromCard(playingCard: PlayingCard) -> PlayingDice? {
        if let dice = playingCard.childNode(withName: "dice") {
            return dice as? PlayingDice
            
        }
        return nil
    }
    
    //Makes the dice a child of the playingCard when it is dropped on a card.
    func drop(playingDice: PlayingDice, on playingCard: PlayingCard) {
        playingDice.name = "dice"
        playingDice.removeFromParent()
        playingCard.addChild(playingDice)
        playingDice.update(position: CGPoint(x:0, y: 0))
        playingDice.size = config.diceSizeFinal
    }
    
    //MARK: PlayerUpdates
    //Adds a player info box to the game when I new player joins.
    mutating func addPlayer(playerName: String, playerNumber: Int, lifeTotal: Int, to scene: SKScene, playerNumberSelf: Int, databaseKey: String) {
        let player = PlayerInfo(lifeTotal: lifeTotal, playerName: playerName, playerNumber: playerNumber, to: scene, databaseKey: databaseKey)
        playerInfos.append(player)
        player.movePlayerInfo(playerNumberSelf: playerNumberSelf)
    }
    
    //Returns a player from a player number.
    func findPlayer(playerNumber: Int) -> PlayerInfo? {
        for playerInfo in playerInfos {
            if playerInfo.playerNumber == playerNumber {
                return playerInfo
            }
        }
        return nil
    }
    
    //Returns a player info at a position.
    func findPlayer(at point: CGPoint) -> PlayerInfo? {
        for playerInfo in playerInfos {
            if playerInfo.contains(point) {
                return playerInfo
            }
        }
        return nil
    }
    
    func reset() {
        for playerInfo in playerInfos {
            playerInfo.removeFromParent()
        }
    }
    
    //MARK: Helpers
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
    
    //Moves playing card to highest zPosition.
    mutating func setActive(card: PlayingCard) {
        card.zPosition = config.getZIndex()
    }
    
    //Moves dice card to highest zPosition.
    mutating func setDiceActive(dice: PlayingDice) {
        dice.zPosition = config.getZIndex()
    }
    
    //Removes all cards from the game.
    mutating func newGame(gameDecks: Deck) {
        for card in cards {
            card.removeFromParent()
        }
        cards = []
        setupCards(gameDecks: gameDecks)
    }
    
    //Returns the diagonal distance between two points.
    func distanceBetween(pointA: CGPoint, pointB: CGPoint) -> Int {
        let lengthX = pow((pointA.x - pointB.x), 2)
        let lengthY = pow((pointA.y - pointB.y), 2)
        let length = (lengthX + lengthY).squareRoot()
        return Int(length)
    }
    
    //Untaps all of the cards when the new turn button is pressed,
    func newTurn(sender: Int) -> [PlayingCard] {
        let database = Database.database().reference().child("Updates")
        var tappedCards: [PlayingCard] = []
        for playingCard in cards {
            if let databaseRef = playingCard.databaseRef {
                database.child(databaseRef).observeSingleEvent(of: .value, with: {(snapshot) in
                    if let value = snapshot.value as? NSDictionary {
                        if let databaseSender = value["Owner"] as? String {
                        let senderInt = Int(databaseSender)
                        if playingCard.tapped && senderInt == sender {
                            self.tapCard(card: playingCard)
                            tappedCards.append(playingCard)
                            Database.database().reference().child("Updates").child(playingCard.databaseRef!).updateChildValues(["Tapped": "false"])
                        }
                        }
                    }
                })
            }
        }
        return tappedCards
    }
    
    //Rotates the card sideways if it is upright and turns it upright if it was sideways.
    func tapCard(card: PlayingCard) {
        let angle: Double = card.tapped ? Double.pi/2 : -Double.pi/2
        let rotation = SKAction.rotate(byAngle: CGFloat(angle), duration: 0.0)
        card.run(rotation)
        
        card.tapped = card.tapped ? false : true
    }
    
    //Moves the card onto the battlefield for searching the deck.
    mutating func displayDeck() {
        let startPos = CGPoint(x:deck.position.x + config.cardSize.width/2 - config.offsetX, y: -config.offsetY - config.cardSize.height * 2)
        //Checks if each card in Cards is in the deck and if so moves them to be displayed
        let sortedCards = cards.sorted(by: { $1.card.name > $0.card.name })
        var i = 0
        for card in sortedCards {
            if card.heldBy == "Deck" {
                setActive(card: card)
                let currentPlayingCard = CurrentPlayingCard(playingCard: card, startPosition: card.position, touchPoint: card.anchorPoint, location: .deck())
                //NOTE: This is integer division to reset the cards to the top of the column every 30 cards
                let j : Int = i/30
                let posX = startPos.x + CGFloat(j) * config.cardSize.width
                let posY = startPos.y - CGFloat(i) * config.cardOffset + config.cardOffset * CGFloat(30 * j)
                let position = CGPoint(x: posX, y: posY)
                currentPlayingCard.move(to: position)
                i = i + 1
            }
        }
    }
    
    //Returns the cards to the origonal place in the deck after being displayed.
    mutating func reconstructDeck(gameCards: [Card]) {
        for (i,card) in gameCards.enumerated() {
            for playingCard in cards {
                if playingCard.card == card {
                    setActive(card: playingCard)
                    let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: playingCard.anchorPoint, location: .deck())
                    let position = CGPoint(x: deck.position.x, y: deck.position.y + CGFloat(i/4))
                    currentPlayingCard.move(to: position)
                    currentPlayingCard.playingCard.texture = SKTexture(imageNamed: config.cardbackName)
                }
            }
        }
    }
    
    //Enlarges the card at the location specified in the top right corner.
    mutating func showPlayingCard(at location: CGPoint, scene: SKScene) {
        // Get node at position
        let node = scene.nodes(at: location)
        if var sprite = node.first as? SKSpriteNode {
            if sprite == labels.cardDisplay {
                sprite = (node[1] as? SKSpriteNode)!
            }
            if sprite.name != nil && sprite.texture != SKTexture(imageNamed: config.cardbackName) {
                labels.cardDisplay.texture = sprite.texture
                labels.cardDisplay.zPosition = config.getZIndex()
            }
            else {
                labels.cardDisplay.texture = nil
            }
        }
    }
    
    mutating func hideCardDisplay() {
        labels.cardDisplay.texture = nil
    }
    
    //Shows an list of specific cards that are outside of the players deck.
    mutating func showTokens(addedTokens: [Card], scene: SKScene) {
        for (i, gameCard) in addedTokens.enumerated() {
            let card = PlayingCard(card: gameCard, size: config.cardSize, databaseRef: nil)
            let j = i/30
            card.anchorPoint = config.cardMiddle
            card.size = config.cardSize
            card.position = CGPoint(x: config.cardSize.width/2 + config.cardSize.width * CGFloat(j), y: -config.cardSize.height/2 - CGFloat(i) * config.cardOffset + config.cardOffset * CGFloat(30 * j))
            card.zPosition = config.getZIndex()
            card.texture = SKTexture(imageNamed: card.card.fileName)
            card.heldBy = "display"
            
            cards.append(card)
            scene.addChild(card)
            
        }
    }
    
    //Removed the tokens from the scene.
    mutating func hideTokens() {
        for playingCard in cards {
            if playingCard.heldBy == "display" {
                cards.remove(at: cards.index(of: playingCard)!)
                playingCard.removeFromParent()
            }
        }
    }
    
    //Orders the cards properly when a card is removed from the middle of a cell
    mutating func updateCardStack(card: CurrentPlayingCard, location: Location, gameBattleDeck: [[Battlefield]], hand: Hand) {
        
        var i : Double   = 0
        switch location {
        case .battlefield(let field, let stack):
            let playingCards = cardsInCell(location: location, gameBattleDeck: gameBattleDeck , hand: hand)
            let battlefield = allBattlefields[field]
            let stack = battlefield[stack]
            for playingCard in playingCards {
                
                let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: playingCard.anchorPoint, location: location)
                let position = CGPoint(x: stack.position.x + config.cardSize.width/2 - config.offsetX, y: stack.position.y - CGFloat(i) * config.cardOffset - config.cardSize.height/2 - config.offsetY)
                currentPlayingCard.move(to: position)
                i = i + 1
            }
            
        case .hand():
            
            let playingCards = cardsInCell(location: location, gameBattleDeck: gameBattleDeck , hand: hand)
            let counter : Double = ((playingCards.count + 1) > 7) ? Double(playingCards.count) : 7.0
            for playingCard in playingCards {
                setActive(card: playingCard)
                let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: playingCard.anchorPoint, location: location)
                let position =  CGPoint(x: config.offsetX + config.spacing + CGFloat((i * 7.0)/counter) * config.cardSize.width, y: hands.position.y)
                i = i + 1
                currentPlayingCard.move(to: position)
            }
            
        default: break
            
        }
    }
    
    //Returns all the cards at a specific lacation in sorted order based on zPosition
    private mutating func cardsInCell(location: Location, gameBattleDeck: [[Battlefield]], hand: Hand) -> [PlayingCard] {
        var playingCards : [PlayingCard] = []
        
        switch location {
            
        case .battlefield(let field, let stack):
            let gameDeck = gameBattleDeck[field]
            let battlefieldCards = gameDeck[stack]
            
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
    mutating func move(currentPlayingCard: CurrentPlayingCard, to location: Location, gameDecks: Deck?, gameBattleDeck: [[Battlefield]]?, hand: Hand?) {
        let playingCard = currentPlayingCard.playingCard
        let newPosition: CGPoint
        switch location {
            
        case .graveyard(let value):
            let graveyard = graveyards[value]
            newPosition = graveyard.position
            playingCard.heldBy = "Graveyard"
            
        case .hand():
            let cardCount = hand!.cards.count - 1
            if cardCount < 7 {
                newPosition = CGPoint(x: -6 * config.offsetX + hands.position.x + CGFloat(cardCount) * config.cardSize.width, y: hands.position.y)
            }
            else {
                newPosition = CGPoint(x: hands.position.x, y: hands.position.y)
            }
            playingCard.heldBy = "Hand"
            currentPlayingCard.move(to: newPosition)
            updateCardStack(card: currentPlayingCard, location: Location.hand(), gameBattleDeck: gameBattleDeck!, hand: hand!)
            return
            
        case .deck():
            let gameDeck = gameDecks
            let cardCount = gameDeck!.cards.count - 1
            let deckPosition = deck.position
            newPosition = CGPoint(x: deckPosition.x, y: deckPosition.y + CGFloat(cardCount)/4)
            playingCard.heldBy = "Deck"
            
        case .battlefield(let field, let stack):
            let graphicsField = allBattlefields[field]
            let graphicsStack = graphicsField[stack]
            let modelField = gameBattleDeck![field]
            let modelStack = modelField[stack]
            let cardCount = modelStack.cards.count - 1
            let deckPosition = graphicsStack.position
            newPosition = CGPoint(x: deckPosition.x + config.cardSize.width/2 - config.offsetX, y: deckPosition.y - CGFloat(cardCount) * config.cardOffset - config.cardSize.height/2 - config.offsetY)
            playingCard.heldBy = "Battlefield"
        case .dataExtract():
            print("Error in move: Called dataExtract")
            newPosition = CGPoint(x:0, y:0)
        default:
            print("Called illegal move to tokens or dataExtract")
            newPosition = CGPoint(x: 0, y: 0)
            
        }
        if playingCard.tapped && playingCard.heldBy != "Battlefield" {
            tapCard(card: playingCard)
        }
        currentPlayingCard.move(to: newPosition)
        if currentPlayingCard.playingCard.heldBy == "Deck" {
            currentPlayingCard.playingCard.texture = SKTexture(imageNamed: config.cardbackName)
        }
    }
    
    //After getting an update from the database, add the image to the local scene in the correct place.
    mutating func addFromDatabase(name: String, field: Int, stack: Int, scene: SKScene) -> PlayingCard {
        let gameCard = Card(name: name)
        let card = PlayingCard(card: gameCard, size: config.cardSize, databaseRef: nil)
        card.anchorPoint = config.cardMiddle
        card.size = config.cardSize
        card.position = CGPoint(x: -100, y: 100)
        card.zPosition = config.getZIndex()
        cards.append(card)
        scene.addChild(card)
        setActive(card: card)
        
        return card
    }
    
    //Deleted a card from the scene
    mutating func deleteCard(playingCard: PlayingCard) {
        playingCard.removeFromParent()
        cards.remove(at: cards.index(of: playingCard)!)
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
            return .deck()
        }
        
        for (i, battlefield) in allBattlefields.enumerated() {
            for (j, stack) in battlefield.enumerated() {
                if stack.contains(position) {
                    return .battlefield(i, j)
                }
            }
        }
        return nil
    }
    
    //Find the card in the graphics that corespond to a card in the model.
    func findPlayingCard(from card: Card) -> PlayingCard {
        for playingCard in cards {
            if playingCard.card == card {
                return playingCard
            }
        }
        fatalError("Couldn't find PlayingCard from Card")
    }
    
    // MARK: - Private
    
    //Updates the counted for number of cards in the deck.
    func update(gameDeck: Deck) {
        deckCount.text = "\(gameDeck.cards.count)"
    }
}
