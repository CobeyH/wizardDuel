//
//  GameScene.swift
//  Wizard Duel
//
//  Created by gary on 16/06/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import SpriteKit
import GameplayKit
#if os(iOS)
import Firebase

public typealias TapGR = UITapGestureRecognizer
public typealias pinchGR = UIPinchGestureRecognizer

#elseif os(OSX)
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
public typealias TapGR = NSClickGestureRecognizer
#endif

class GameScene: SKScene {
    
    // MARK: - Properties
    let game = Game()
    public var gameGraphics = GameGraphics()
    private var labels = Labels()
    private lazy var database: WDDatabase = {
        let database =  WDDatabase(gameScene: self)
        return database
    }()
    private var currentPlayingCard: CurrentPlayingCard?
    private var currentMovingDice: PlayingDice?
    weak var viewDelegate: GameSceneDelegate?
    public var playerNumber = 0
    private var mulliganCount = 0
    
    
    // MARK: - Lifecycle
    override func sceneDidLoad() {
        super.sceneDidLoad()
        anchorPoint = CGPoint(x: 0, y: 1)
        //Log in to the firebase database and set up observes for changes in the database
        
        let login = LoginInfo()
        Auth.auth().signIn(withEmail: login.username, password: login.password) { (user, error) in
            if error != nil {
                print("The following error occured while signing into the Database: ", error!)
            } else {
                print("Login Successful")
            }
        }
        
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.size = view.bounds.size
        gameGraphics.setup(width: size.width, height: size.height)
        gameGraphics.setupCards(from: game.deck)
        
        labels.setUpLabels(width: size.width, height: size.height, to: self)
        gameGraphics.addChildren(to: self)
        gameGraphics.setupBackground(to: self)
        

#if os(OSX)
       //Creates a tracking area on the mac to track mouse hover movements.
        let options = [NSTrackingArea.Options.mouseMoved, NSTrackingArea.Options.activeInKeyWindow] as NSTrackingArea.Options
        let trackingArea = NSTrackingArea(rect:(view.frame),options:options,owner:self,userInfo:nil)
        view.addTrackingArea(trackingArea)
#endif
    }
    
#if os(iOS)
    
    
#elseif os(OSX)
    //Tracks mouse movement and sets the card display if a playing card is at the location.
    override func mouseMoved(with event: NSEvent) {
        // Get mouse position in scene coordinates
        let location = event.location(in: self)
        gameGraphics.showPlayingCard(at: location, scene: self)
    }
#endif
    func mulligan() {
        mulliganCount = mulliganCount + 1
        newGame()
    }
    
    func keepHand() {
        mulliganCount = 0
        labels.removeButtons()
        game.deckURL = nil
    }
    
    func newTurn() {
        let tappedCards = gameGraphics.untapCards(for: playerNumber)
        drawCard()
        for playingCard in tappedCards {
            database.database.child("Updates").child(playingCard.databaseRef!).updateChildValues(["Tapped": "false"])
        }
    }
    
    func tapOn(playerInfo: PlayerInfo, touchLocation: CGPoint) {
        let childPoint = convert(touchLocation, to: playerInfo)
        //Checks if the click is near the life up label and increases the life if it is.
        if gameGraphics.distanceBetween(pointA: playerInfo.healthUpLabel.position, pointB: childPoint) < 10 {
            playerInfo.lifeUp()
        }
        else if gameGraphics.distanceBetween(pointA: playerInfo.healthDownLabel.position, pointB: childPoint) < 10 {
            playerInfo.lifeDown()
        }
        //Updates life total on the player Info
        database.players.child(playerInfo.databaseKey).updateChildValues(["lifeTotal": String(playerInfo.getLife())])
    }
    
    // Triggered when a single click is detected with no dragging
    @objc func tap(sender: TapGR) {
        if sender.state != .ended {
            return
        }
        var touchLocation: CGPoint = sender.location(in: sender.view)
        touchLocation = self.convertPoint(fromView: touchLocation)
        //Check each of the buttons to see if they have been tapped
        if labels.mulliganButton != nil && labels.mulliganButton!.contains(touchLocation) {
            mulligan()
        } else if labels.newGameButton.contains(touchLocation) {
            guard let viewDelegate = viewDelegate, viewDelegate.newGame(currentGameState: game.state, gameScene: self) else { return }
            newGame()
        } else if labels.keepButton.contains(touchLocation) {
            keepHand()
        } else if labels.isNewTurnTapped(point: touchLocation) {
            newTurn()
            return
        } else if labels.isShuffleTapped(point: touchLocation) {
            game.deck.cards.shuffle()
            gameGraphics.reconstructDeck(gameCards: game.deck.cards)
        }
        
        //Increased the dice value on a playing card if a dice is tapped
        if let playingCard = gameGraphics.cardFrom(position: touchLocation) {
            if let playingDice = playingCard.childNode(withName: "dice") as? PlayingDice {
                if playingDice.contains(convert(touchLocation, to: playingDice)) {
                    playingDice.dice.diceUp()
                    playingDice.setTexture()
                    database.updateDatabase(playingCard: playingCard)
                    return
                }
            }
        }
        //Taps a card on the battlefield.
        if let playingCard = gameGraphics.cardFrom(position: touchLocation) {
            if playingCard.heldBy == "Battlefield" {
                gameGraphics.tap(card: playingCard)
                database.database.child("Updates").child(playingCard.databaseRef!).updateChildValues(["Tapped": String(playingCard.tapped), "Sender": String(playerNumber)])
            }
        }
        //Checks if a a player info box is tapped and updates life totals locally and in the database.
        if let playerInfo = gameGraphics.findPlayer(at: touchLocation) {
            tapOn(playerInfo: playerInfo, touchLocation: touchLocation)
        }
    }

    //If a double tap is detected on the deck a card will be drawn
    @objc func doubleTap(by sender: TapGR) {
        if sender.state == .ended {
            var touchLocation: CGPoint = sender.location(in: sender.view)
            touchLocation = self.convertPoint(fromView: touchLocation)
            if let playingCard = gameGraphics.cardFrom(position: touchLocation) {
                if playingCard.heldBy == "Deck" {
                    self.drawCard()
                }
            }
        }
    }

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            touchDown(atPoint: location)
        }
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            touchUp(atPoint: location)
        }
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            touchMoved(toPoint: location)
            moveDice(atPoint: location)
        }
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentPlayingCard = currentPlayingCard {
            currentPlayingCard.returnToOriginalLocation()
        }
        super.touchesCancelled(touches, with: event)
    }
    
    #elseif os(OSX)
    // MARK: - Action Triggers
    //Triggered when the mouse is pressed down. It is only used to call other methods depending on the number of clicks
    override func mouseDown(with event: NSEvent) {
        touchDown(atPoint: event.location(in: self))
    }
    
    //Triggers on mouse right click. Decreases the counter on a dice
    override func rightMouseDown(with event: NSEvent) {
        let position = event.location(in: self)
        if let playingCard = gameGraphics.cardFrom(position: position) {
            if let playingDice = playingCard.childNode(withName: "dice") as? PlayingDice {
                if playingDice.contains(convert(position, to: playingDice)) {
                    playingDice.dice.diceDown()
                    database.updateDatabase(playingCard: playingCard)
                    if playingDice.dice.value < 1 {
                        gameGraphics.deleteDice(from: self, toDelete: playingDice)
                    } else {
                        playingDice.setTexture()
                    }
                    return
                }
            }
            //Moves a playing card to the button of the deck when right clicked
            else if gameGraphics.deck.contains(position) {
                let temp = playingCard.card
                game.deck.removeBottom()
                game.deck.cards.insert(temp, at: 0)
                gameGraphics.reconstructDeck(gameCards: game.deck.cards)
            }
        }
    }
    
    
    //Triggers on mouse dragging
    override func mouseDragged(with event: NSEvent) {
        touchMoved(toPoint: event.location(in: self))
        moveDice(atPoint: event.location(in: self))
    }
    
    //Triggers when the mouse is released
    override func mouseUp(with event: NSEvent) {
        touchUp(atPoint: event.location(in: self))
    }
    
    //Triggered when a key on the keyboard is pressed
    override func keyDown(with event: NSEvent) {
        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
        case [.command] where event.characters == "f":
            gameGraphics.displayDeck()
        case [.command] where event.characters == "c":
            Database.database().reference().child("players").removeValue()
        case [.command] where event.characters == "t":
            let addedTokens = game.createTokens()
            gameGraphics.showTokens(addedTokens: addedTokens, scene: self)
        case [.command] where event.characters == "b":
            gameGraphics.changeBackground(of: self)
        default:
            break
        }
        if let firstCharacter = event.characters?.first {
            if firstCharacter == "\u{1b}" {
                //Removes tokens from the game or returns the deck to non-display mode.
                for playingCard in gameGraphics.cards {
                    if playingCard.heldBy == "display" {
                        gameGraphics.hideTokens()
                    } else {
                        game.deck.cards.shuffle()
                        gameGraphics.reconstructDeck(gameCards: game.deck.cards)
                    }
                }
            }
            //Decreases life by 1
            else if firstCharacter == "-" {
                if let playerSelf = gameGraphics.findPlayer(with: playerNumber) {
                    playerSelf.lifeDown()
                    database.players.child(playerSelf.databaseKey).updateChildValues(["lifeTotal": String(playerSelf.getLife())])
                }
            }
            //Increases life by 1. It is a = and not a + so the user does not have to press shift.
            else if firstCharacter == "=" { 
                if let playerSelf = gameGraphics.findPlayer(with: playerNumber) {
                    playerSelf.lifeUp()
                    database.players.child(playerSelf.databaseKey).updateChildValues(["lifeTotal": String(playerSelf.getLife())])
                }
            }
        }
    }
#endif
    
    // MARK: - Touch Responders
    //These are all the actions that are called by the triggers.
    
    //Called when the mouse is pressed down. This sets a card to active in order it initiate a movement of the card.
    private func touchDown(atPoint point: CGPoint) {
        if gameGraphics.isDiceTapped(at: point) {
            currentMovingDice = gameGraphics.addDice(to: self)
        }
        if let playingCard = gameGraphics.cardFrom(position: point) {
            let dicePoint = convert(point, to: playingCard)
            if let dice = gameGraphics.findDice(at: dicePoint) {
                gameGraphics.setDiceActive(dice: dice)
            }
        }
        if let dice = gameGraphics.findDice(at: point) {
            currentMovingDice = dice
            return
        }
        guard
        //Checks if the card is allowed to be moved.
            let playingCard = gameGraphics.cardFrom(position: point),
            let parent = playingCard.parent,
            let location = game.location(from: playingCard.card),
            game.canMove(card: playingCard.card)
            
            else {
                return
        }
        //Set the card ready to be moved.
        let touchPoint = playingCard.convert(point, from: parent)
        gameGraphics.setActive(card: playingCard)
        currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: touchPoint, location: location)
        
    }
    
    //Updates the position of the dice to the new point.
    private func moveDice(atPoint point: CGPoint) {
        currentMovingDice?.update(position: point)
    }
    
    //Updates the position of the card as the card is being dragged
    private func touchMoved(toPoint pos: CGPoint) {
        guard let currentPlayingCard = currentPlayingCard else { return }
        if gameGraphics.findDice(at: pos) == nil {
            currentPlayingCard.update(position: pos)
        }
    }
    
    //Called when the mouse is released. It calls the move function when a card has been dragged and released to a new location
    private func touchUp(atPoint pos: CGPoint) {
        // Handle dropping a dice
        if let dice = currentMovingDice {
            if let playingCard = gameGraphics.cardFrom(position: pos) {
                gameGraphics.drop(playingDice: dice, on: playingCard)
                database.updateDatabase(playingCard: playingCard)
            } else if let playingCard = gameGraphics.cardOverlapping(rectangle: dice.frame) {
                gameGraphics.drop(playingDice: dice, on: playingCard)
                database.updateDatabase(playingCard: playingCard)
            } else {
                gameGraphics.deleteDice(from: self, toDelete: dice)
            }
            currentMovingDice = nil
        }
        // Handle dropping a card
        guard let currentPlayingCard = currentPlayingCard else { return }
        //Drop location is set as the location where the card is released.
        let startHeldBy = currentPlayingCard.playingCard.heldBy
        if let dropLocation = gameGraphics.dropLocation(playingCard: currentPlayingCard.playingCard, game: game) {
            let toDeleteCard = currentPlayingCard.playingCard
            moveLocation(currentPlayingCard: currentPlayingCard, location: dropLocation)
            if toDeleteCard.heldBy != "Battlefield" && startHeldBy == "Battlefield" {
                database.deleteFromDatabase(playingCard: toDeleteCard)
                currentPlayingCard.playingCard.databaseRef = nil
                self.currentPlayingCard = nil
                return
            }
            database.updateDatabase(playingCard: currentPlayingCard.playingCard)
        } else {
            currentPlayingCard.returnToOriginalLocation()
        }
        self.currentPlayingCard = nil
    }
    
    //Moves a card from one location to another without dragging the card to the new location.
    func moveLocation(currentPlayingCard: CurrentPlayingCard, location: Location) {
        do {
            //Updates the model by removing the card from the origonal location and adding it to the new location.
            gameGraphics.setActive(card: currentPlayingCard.playingCard)
            try game.move(card: currentPlayingCard, to: location)
            //Updates the view by moving the image to the correct animation
            gameGraphics.move(currentPlayingCard: currentPlayingCard, to: location, gameDecks: game.deck, gameBattleDeck: game.allBattlefields, hand: game.hands)
            gameGraphics.updateCardStack(card: currentPlayingCard, location: currentPlayingCard.location, gameBattleDeck: game.allBattlefields, hand: game.hands)
        } catch GameError.invalidMove {
            currentPlayingCard.returnToOriginalLocation()
            print("Invalid Move")
        }
        catch {
            // Something went wrong - don't know what
            currentPlayingCard.returnToOriginalLocation()
        }
        gameGraphics.update(gameDeck: game.deck)
        self.currentPlayingCard = nil
        
    }
    
    //Called when the mouse is clicked twice. It calls the methods to move a card from the deck into the hand
    func doubleTap(at point: CGPoint) {
        
        let playingCard = gameGraphics.cardFrom(position: point)
        
        if playingCard!.heldBy == "Deck" {
            self.drawCard()
        }
    }
    
    //Moves a card from the deck into the hand.
    func drawCard() {
        if let card = game.deck.bottomCard {
        let playingCard = gameGraphics.findPlayingCard(from: card)
            currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: playingCard.position, location: .deck())
            moveLocation(currentPlayingCard: currentPlayingCard!, location: .hand())
        gameGraphics.update(gameDeck: game.deck)
        }
        else {
            print("Failed to draw a card")
        }
    }

    private func requestNewGame() {
        guard let viewDelegate = viewDelegate, viewDelegate.newGame(currentGameState: game.state, gameScene: self) else { return }
        newGame()
    }
}


// MARK: - ViewControllerDegelate
extension GameScene: ViewControllerDelegate {
    var gameState: Game.State {
        return game.state
    }
    
    //Sets up a new game from scratch.
    func newGame() {
        //TODO Make this cross platform
        #if os(OSX)
        game.new()
        #endif
        gameGraphics.newGame(with: game.deck)
        gameGraphics.addCards(to: self)
        var commander: CurrentPlayingCard?
        //If the deck has a card marked as commender moves it to the command zone.
        for playingCard in gameGraphics.cards {
            if playingCard.card.name == game.commander {
                commander = CurrentPlayingCard(playingCard: playingCard, startPosition: gameGraphics.deck.position, touchPoint: gameGraphics.deck.position, location: .deck())
                moveLocation(currentPlayingCard: commander!, location: .graveyard(2))
            }
        }
        //Draws the correct number of cards for the player.
        if mulliganCount < 7 {
            for _ in 0..<(7 - mulliganCount % 7) {
                drawCard()
            }
            //Gives one free mulligan.
            if mulliganCount != 0 {
                drawCard()
            }
        }
        //code to only do on the first iteration.
        if mulliganCount == 0 {
            gameGraphics.reset()
            labels.addMulligan(to: self)
            
            if let playerName = UserDefaults.standard.string(forKey: "PlayerName") {
                database.addToDatabase(playerName)
            }
            else {
                print("No Player Name Entered")
            }
        }
    }
}
