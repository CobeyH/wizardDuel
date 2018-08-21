//
//  GameScene.swift
//  Freegraveyard2
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
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore

public typealias TapGR = NSClickGestureRecognizer
#endif

class GameScene: SKScene {
    // MARK: - Properties

    let game = Game()
    private var gameGraphics = GameGraphics()
    private var labels = Labels()
    private var currentPlayingCard: CurrentPlayingCard?
    weak var viewDelegate: GameSceneDelegate?
    private var playerNumber = 0
    private var mulliganCount = 0
    
    
    // MARK: - Lifecycle
    override func sceneDidLoad() {
        super.sceneDidLoad()
        anchorPoint = CGPoint(x: 0, y: 1)
        //Log in to the firebase database and set up observes for changes in the database
        FirebaseApp.configure()
        let login = loginInfo()
        Auth.auth().signIn(withEmail: login.username, password: login.password) { (user, error) in
            if error != nil {
                print(error!)
            } else {
                print("login Successful")
            }
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.size = view.bounds.size
        gameGraphics.setup(width: size.width, height: size.height)
        gameGraphics.setupCards(gameDecks: game.deck)
        
        
        labels.setUpLabels(width: size.width, height: size.height, to: self)
        gameGraphics.addChildren(to: self)
        gameGraphics.setupBackground(to: self)

#if os(iOS)
       
#elseif os(OSX)
       //Creates a tracking area on the mac to track mouse hover movements.
        let options = [NSTrackingArea.Options.mouseMoved, NSTrackingArea.Options.activeInKeyWindow] as NSTrackingArea.Options
        let trackingArea = NSTrackingArea(rect:(view.frame),options:options,owner:self,userInfo:nil)
        view.addTrackingArea(trackingArea)
#endif
    }
    
#if os(iOS)
    //Recognized pinch gestures anywhere on the screen and triggers the deck to be displayed or hidden.
    @objc func pinch(sender: pinchGR) {
        if sender.state == .ended {
            if sender.scale < 0.4 {
                game.deck.cards.shuffle()
                gameGraphics.reconstructDeck(gameCards: game.deck.cards)
                
            } else if sender.scale > 1.5 {
                gameGraphics.displayDeck()
            }
        }
    }
    
#elseif os(OSX)
    //Tracks mouse movement and sets the card display if a playing card is at the location.
    override func mouseMoved(with event: NSEvent) {
        // Get mouse position in scene coordinates
        let location = event.location(in: self)
        gameGraphics.showPlayingCard(at: location, scene: self)
    }
#endif
    
    // Triggered when a single click is detected with no dragging
    @objc func tap(sender: TapGR) {
        if sender.state == .ended {
            var touchLocation: CGPoint = sender.location(in: sender.view)
            touchLocation = self.convertPoint(fromView: touchLocation)
            //On new game checks if the mulligan button has been pressed
            if labels.mulliganButton != nil {
                if (labels.mulliganButton!.contains(touchLocation)) {
                    mulliganCount = mulliganCount + 1
                    newGame()
                }
            }
            
            if labels.newGameButton.contains(touchLocation) {
                guard let viewDelegate = viewDelegate, viewDelegate.newGame(currentGameState: game.state, gameScene: self) else { return }
                newGame()
            }
            
            //On new game checks if the keep hand button has been pressed.
            if labels.keepButton.contains(touchLocation) {
                mulliganCount = 0
                labels.removeButtons()
                game.deckURL = nil
            }
            //Checks if the new turn button has been pressed.
            else if labels.isNewTurnTapped(point: touchLocation) {
                let tappedCards = gameGraphics.newTurn(sender: playerNumber)
                drawCard()
                for playingCard in tappedCards {
                    Database.database().reference().child("Updates").child(playingCard.databaseRef!).updateChildValues(["Tapped": "false"])
                }
                return
            }
            //Checks if the shuffle button has been tapped.
            else if labels.isShuffleTapped(point: touchLocation) {
                game.deck.cards.shuffle()
                gameGraphics.reconstructDeck(gameCards: game.deck.cards)
            //Checks if the import button is pressed on iOS to import the deck.
            } else if labels.isImportPressed(point: touchLocation) {
                guard let viewDelegate = viewDelegate else { return }
                viewDelegate.importDeck()

            }
            
            //Increased the dice value on a playing card if a dice is tapped
            if let playingCard = gameGraphics.cardFrom(position: touchLocation) {
                if let playingDice = playingCard.childNode(withName: "dice") as? PlayingDice {
                    if playingDice.contains(convert(touchLocation, to: playingDice)) {
                        playingDice.dice.diceUp()
                        playingDice.setTexture()
                        updateDatabase(playingCard: playingCard)
                        return
                    }
                }
            }
            //Taps a card if it is pressed and the tap is not on a dice.
            if let playingCard = gameGraphics.cardFrom(position: touchLocation) {
                if playingCard.heldBy == "Battlefield" {
                    gameGraphics.tapCard(card: playingCard)
                    Database.database().reference().child("Updates").child(playingCard.databaseRef!).updateChildValues(["Tapped": String(playingCard.tapped), "Sender": String(playerNumber)])
                }
            }
            //Checks if a a player info box is tapped and updates life totals locally and in the database.
            if let playerInfo = gameGraphics.findPlayer(at: touchLocation) {
                let childPoint = convert(touchLocation, to: playerInfo)
                //Checks if the click is near the life up label and increases the life if it is.
                if gameGraphics.distanceBetween(pointA: playerInfo.healthUpLabel.position, pointB: childPoint) < 10 {
                    playerInfo.lifeUp()
                }
                else if gameGraphics.distanceBetween(pointA: playerInfo.healthDownLabel.position, pointB: childPoint) < 10 {
                    playerInfo.lifeDown()
                }
                //Updates life total on the player Info
                Database.database().reference().child("players").child(playerInfo.databaseKey).updateChildValues(["lifeTotal": String(playerInfo.getLife())])
            }
            
        }
    }
    
    //If a double tap is detected on the deck a card will be drawn
    @objc func doubleTap(sender: TapGR) {
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

    // MARK: - Database
    //Sends a card and location to the database when a card is moved
    func updateDatabase(playingCard: PlayingCard) {
        let cardUpdate = Database.database().reference().child("Updates")
        var value = 0
        //This takes the location that the sender dropped the card.
        
        if let location = game.location(from: playingCard.card) {
            if case .battlefield(let field, let stack) = location {
                if playingCard.children.count != 0 {
                    let dice = playingCard.childNode(withName: "dice") as! PlayingDice
                    value = dice.dice.value
                }
                //Checks if the playingcard has an ID, and if not, assigns it a new ID.
                let databaseRef = playingCard.databaseRef ?? cardUpdate.childByAutoId().key
                var updateDictionary = ["Sender": String(playerNumber), "Card": playingCard.card.name, "Field": String(field), "Stack": String(stack), "Tapped": String(playingCard.tapped), "DiceValue": String(value)]
                if playingCard.databaseRef == nil {
                    playingCard.databaseRef = databaseRef
                    updateDictionary["Owner"] = String(self.playerNumber)
                    cardUpdate.child(databaseRef).setValue(updateDictionary)
                }
                else {
                    cardUpdate.child(databaseRef).updateChildValues(updateDictionary)
                }
            }
        }
    }
    
    
    //Adds the player to the database when they join the game
    func addToDatabase(_ player: String) {
        
        //Creates a new child database to store the players names.
        let databaseRef = Database.database().reference()
        let playerUpdate = databaseRef.child("players")
        //Accesses the database a sigle time to retrieve the players names.
        playerUpdate.observeSingleEvent(of: .value, with: { (snapshot) in
            self.playerNumber = Int(snapshot.childrenCount)
            let playerDictonary = ["player": player, "playNumber": String(self.playerNumber), "lifeTotal": "40"]
            let databaseRef = playerUpdate.childByAutoId()
            self.gameGraphics.addPlayer(playerName: player, playerNumber: self.playerNumber, lifeTotal: 40, to: self, playerNumberSelf: self.playerNumber, databaseKey: databaseRef.key)
                databaseRef.setValue(playerDictonary) {
                (error, reference) in
                if error != nil {
                    print(error!)
                }
                else {
                    print("Player Saved")
                    for player in snapshot.children.allObjects as! [DataSnapshot] {
                        self.processPlayerUpdate(snapshot: player)
                    }
                }
            }
            self.retrieveUpdates()
        }) { (error) in
            print(error.localizedDescription)
        }
        databaseRef.child("Updates").removeValue()
    }
    
    //Retrieves an update or addition of a card from the database. Can fetch new dice, dice updates, card taps, and new cards.
    func retrieveUpdates() {
        let cardUpdate = Database.database().reference().child("Updates")
        cardUpdate.observe(.childAdded) { (snapshot) in
            if snapshot.childrenCount != 0 {
                self.processUpdate(snapshot: snapshot)
            }
        }
        cardUpdate.observe(.childChanged, with: { (snapshot) in
            self.processUpdate(snapshot: snapshot)
        })
        
        //Deletes a card from the database if the card is removed from the battlefield
        cardUpdate.observe(.childRemoved, with: { (snapshot) in
            if let snapshotValue = snapshot.value as? Dictionary<String,String> {
                let owner = Int(snapshotValue["Owner"]!)
                let sender = Int(snapshotValue["Sender"]!)
                let stack = Int(snapshotValue["Stack"]!)
                let relativeField = Int(snapshotValue["Field"]!)
                if owner != self.playerNumber {
                    let fieldNumber = self.findField(sender: sender!, relativeField: relativeField!)
                    for playingCard in self.gameGraphics.cards.reversed() {
                        if playingCard.databaseRef == snapshot.key {
                            self.game.allBattlefields[fieldNumber][stack!].removeCard(card: playingCard.card)
                            self.gameGraphics.deleteCard(playingCard: playingCard)
                        }
                    }
                }
            }
        })
        let playerUpdate = Database.database().reference().child("players")
        
        playerUpdate.observe(.childAdded) { (snapshot) in
            if snapshot.childrenCount != 0 {
                self.processPlayerUpdate(snapshot: snapshot)
            }
        }
        
        playerUpdate.observe(.childChanged, with: { (snapshot) in
            self.processPlayerUpdate(snapshot: snapshot)
        })
    }
    
    //Processes the update of card on the local game to unsure that all version of the game are up to date with each other.
    func processUpdate(snapshot: DataSnapshot) {
        //Retrieves all the information from the snapshot.
        if let snapshotValue = snapshot.value as? Dictionary<String,String> {
            if let cardName = snapshotValue["Card"],
                let sender = Int(snapshotValue["Sender"]!),
                let stack = Int(snapshotValue["Stack"]!),
                let relativeField = Int(snapshotValue["Field"]!),
                let cardTapped = Bool(snapshotValue["Tapped"]!),
                let diceValue = Int(snapshotValue["DiceValue"]!) {

                let fieldNumber = findField(sender: sender, relativeField: relativeField)
                //Prevents updates from the sender to be recieved by the sender again.
                if sender != self.playerNumber {
                    //Finds the playing card with the correct ID
                    var playingCard = self.gameGraphics.cards.filter({
                        let databaseRef = $0.databaseRef
                        return databaseRef == snapshot.key
                    }).first
            
                    var location = Location.dataExtract()
                    
                    //Updates the playing card if one is found other wise creates a new card locally.
                    if let playingCard = playingCard {
                        if let previousLocation = self.gameGraphics.dropLocation(from: playingCard.position, playingCard: playingCard, game: self.game) {
                            location = previousLocation
                            if diceValue > 0 && playingCard.children.count == 0 {
                               let newPlayingDice = gameGraphics.newDice(to: self)
                                gameGraphics.drop(playingDice: newPlayingDice, on: playingCard)
                            }
                            else if playingCard.children.count != 0 && diceValue == 0{
                                playingCard.removeAllChildren()
                            }
                            else {
                                if let playingDice = gameGraphics.findDiceFromCard(playingCard: playingCard) {
                                    playingDice.dice.value = diceValue
                                    playingDice.setTexture()
                                }
                            }
                        }
                    } else {
                        let newPlayingCard = self.gameGraphics.addFromDatabase(name: cardName, field: fieldNumber, stack: stack, scene: self)
                        newPlayingCard.databaseRef = snapshot.key
                        playingCard = newPlayingCard
                    }
                    
                    if let playingCard = playingCard {
                        let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: playingCard.position, location: location)
                        if currentPlayingCard.playingCard.tapped != cardTapped {
                            self.gameGraphics.tapCard(card: currentPlayingCard.playingCard)
                            return
                        }
                        
                        let battlefieldLocation = Location.battlefield(fieldNumber, stack)
                        self.moveLocation(currentPlayingCard: currentPlayingCard, location:  battlefieldLocation)
                        
                        
                    } else {
                        print("Error: Card not found or created")
                    }
                }
            }
        }
    }
    
    //Processes an update when a new player is added to the database or life is changed. Creates a player info label or updates the existing one.
    private func processPlayerUpdate(snapshot: DataSnapshot) {
        if let snapshotValue = snapshot.value as? Dictionary<String,String> {
            if let playerName = snapshotValue["player"],
                let playerNumber = Int(snapshotValue["playNumber"]!),
                let lifeTotal = Int(snapshotValue["lifeTotal"]!) {
                    if let player = gameGraphics.findPlayer(playerNumber: playerNumber) {
                        player.lifeTotal = lifeTotal
                        player.updateLife()
                        
                    } else {
                        gameGraphics.addPlayer(playerName: playerName, playerNumber: playerNumber, lifeTotal: lifeTotal, to: self, playerNumberSelf: self.playerNumber, databaseKey: snapshot.key)
                    }
                }
        }
    }
        
    //Removes a playing card from the database.
    private func deleteFromDatabase(playingCard: PlayingCard) {
        if playingCard.databaseRef != nil {
            Database.database().reference().child("Updates").child((playingCard.databaseRef)!).removeValue()
        }
        else {
            print("Failed to remove playing card from database")
        }
    }
    
    //Determines what field to place a card on relative to the local user to ensure consistant player order.
    private func findField(sender: Int, relativeField: Int) -> Int {
        return (4 + sender - self.playerNumber + relativeField) % 4
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
                    updateDatabase(playingCard: playingCard)
                    if playingDice.dice.value < 1 {
                        gameGraphics.deleteDice(to: self, toDelete: playingDice)
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
                if let playerSelf = gameGraphics.findPlayer(playerNumber: playerNumber) {
                    playerSelf.lifeDown()
                    Database.database().reference().child("players").child(playerSelf.databaseKey).updateChildValues(["lifeTotal": String(playerSelf.getLife())])
                }
            }
            //Increases life by 1. It is a = and not a + so the user does not have to press shift.
            else if firstCharacter == "=" {
                if let playerSelf = gameGraphics.findPlayer(playerNumber: playerNumber) {
                    playerSelf.lifeUp()
                    Database.database().reference().child("players").child(playerSelf.databaseKey).updateChildValues(["lifeTotal": String(playerSelf.getLife())])
                }
            }
        }
    }
#endif
    
    // MARK: - Touch Responders
    //These are all the actions that are called by the triggers.
    
    //Called when the mouse is pressed down. This sets acard to active in order it initiate a movement of the card.
    private func touchDown(atPoint point: CGPoint) {
        if gameGraphics.isDiceTapped(point: point) {
            let _ = gameGraphics.newDice(to: self)
        }
        if let playingCard = gameGraphics.cardFrom(position: point) {
            let dicePoint = convert(point, to: playingCard)
            if let dice = gameGraphics.findDice(point: dicePoint) {
                gameGraphics.setDiceActive(dice: dice)
            }
        }
        if gameGraphics.findDice(point: point) != nil {
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
        if let dice = gameGraphics.findDice(point: point) {
            dice.update(position: point)
        }
    }
    
    //Updates the position of the card as the card is being dragged
    private func touchMoved(toPoint pos: CGPoint) {
        guard let currentPlayingCard = currentPlayingCard else { return }
        if gameGraphics.findDice(point: pos) == nil {
            currentPlayingCard.update(position: pos)
        }
    }
    
    //Called when the mouse is released. It calls the move function when a card has been dragged and released to a new location
    private func touchUp(atPoint pos: CGPoint) {
        if let dice = gameGraphics.findDice(point: pos) {
            if let playingCard = gameGraphics.cardFrom(position: pos) {
                gameGraphics.drop(playingDice: dice, on: playingCard)
                updateDatabase(playingCard: playingCard)
            }
        }
        guard let currentPlayingCard = currentPlayingCard else { return }
        //Drop location is set as the location where the card is released.
        let startHeldBy = currentPlayingCard.playingCard.heldBy
        if let dropLocation = gameGraphics.dropLocation(from: pos, playingCard: currentPlayingCard.playingCard, game: game) {
            let toDeleteCard = currentPlayingCard.playingCard
            moveLocation(currentPlayingCard: currentPlayingCard, location: dropLocation)
            if toDeleteCard.heldBy != "Battlefield" && startHeldBy == "Battlefield" {
                deleteFromDatabase(playingCard: toDeleteCard)
                currentPlayingCard.playingCard.databaseRef = nil
                self.currentPlayingCard = nil
                return
            }
            
            updateDatabase(playingCard: currentPlayingCard.playingCard)
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
        game.new()
        gameGraphics.newGame(gameDecks: game.deck)
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
                addToDatabase(playerName)
            }
            else {
                print("No Player Name")
            }
        }
    }
    
}
