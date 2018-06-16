//
//  GameScene.swift
//  Freegraveyard2
//
//  Created by gary on 16/06/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import SpriteKit
import GameplayKit
import FirebaseDatabase
import FirebaseAuth

class GameScene: SKScene {
    // MARK: - Properties

    private let game = Game()
    private var gameGraphics = GameGraphics()
    private var labels = Labels()
    private var currentPlayingCard: CurrentPlayingCard?
    weak var viewDelegate: GameSceneDelegate?
    private let playerNumber: Int = 0

    // MARK: - Lifecycle
    override func sceneDidLoad() {
        super.sceneDidLoad()
        anchorPoint = CGPoint(x: 0, y: 1)
        
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.size = view.bounds.size
        gameGraphics.setup(width: size.width, height: size.height)
        gameGraphics.setupCards(gameDecks: game.deck)
        gameGraphics.setupBackground(to: self)
        
        labels.setUpLabels(width: size.width, height: size.height, to: self)
        
        gameGraphics.addChildren(to: self)
        gameGraphics.setupBackground(to: self)
    
    }
    
    // see if the hit node is a card in the battle field and if so rotate it
    @objc func tap(sender: NSClickGestureRecognizer) {
        if sender.state == .ended {
            var touchLocation: CGPoint = sender.location(in: sender.view)
            touchLocation = self.convertPoint(fromView: touchLocation)
            
            if labels.isNewGameTapped(point: touchLocation) {
                requestNewGame()
                
                return
            }
            if labels.isNewTurnTapped(point: touchLocation) {
                gameGraphics.newTurn()
                return
            }
            if let playingDice = gameGraphics.findDice(point: touchLocation) {
                playingDice.dice.diceUp()
                playingDice.setTexture()
            }
            
            if let playingCard = gameGraphics.cardFrom(position: touchLocation) {
                if playingCard.heldBy == "Battlefield" {
                gameGraphics.tapCard(card: playingCard)
                    
            }
            }
        }
        
    }
    
    @objc func doubleTap(sender: NSClickGestureRecognizer) {
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
    func updateDatabase(playingCard: PlayingCard) {
        let cardUpdate = Database.database().reference().child("Updates")
        if let location = game.location(from: playingCard.card) {
        if case .battlefield(let field, let stack) = location {
            let updateDictionary = ["Sender": Auth.auth().currentUser?.email,"Card": playingCard.card.fileName, "Field": String(field), "Stack": String(stack)]
            cardUpdate.childByAutoId().setValue(updateDictionary) {
                (error, reference) in
                if error != nil {
                    print(error!)
                }
                else {
                    print("Update Saved")
                }
            }
            
            
            } else {
            debugPrint("Not a location update, returning…")
            }
        }
        
    }
    
    
    func updatePlayer(_ player: String) {
        let playerUpdate = Database.database().reference().child("players")
        
        
        playerUpdate.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value {
                
            print(value)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
                playerUpdate.childByAutoId().setValue(player) {
                    (error, reference) in
                    if error != nil {
                        print(error!)
                    }
                    else {
                        print("Player Saved")
                    }
                }
        
    }
    
    func retrieveUpdates() {
        let cardUpdate = Database.database().reference().child("Updates")
        cardUpdate.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let cardName = snapshotValue["Card"]!
            let sender = snapshotValue["Sender"]!
            print(cardName, sender)
        }
    }
    

    // MARK: - Action Triggers
    //Triggered when the mouse is pressed down. It is only used to call other methods depending on the number of clicks
    override func mouseDown(with event: NSEvent) {
            touchDown(atPoint: event.location(in: self))
    }
    
    //Triggers on mouse right click
    override func rightMouseDown(with event: NSEvent) {
        let position = event.location(in: self)
        if let playingCard = gameGraphics.cardFrom(position: position) {
            if playingCard.texture != SKTexture(imageNamed: "cardback") {
              labels.setCardDisplay(playingCard: playingCard)
            }
    
        }
        else {
            labels.cardDisplay.texture = nil
        }
        labels.cardDisplay.color = .clear
        if let playingDice = gameGraphics.findDice(point: position) {
            playingDice.dice.diceDown()
            if playingDice.dice.value < 1 {
                gameGraphics.deleteDice(to: self, toDelete: playingDice)
            }
            else {
                playingDice.setTexture()
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
    
    override func keyDown(with event: NSEvent) {
        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
        case [.command] where event.characters == "f":
            print("Command-F")
            gameGraphics.displayDeck()
        default:
            break
        }
        if let firstCharacter = event.characters?.first {
            if firstCharacter == "\u{1b}" {
                print("Esc")
                gameGraphics.reconstructDeck()
            }
        }
        
    }

     
    // MARK: - Touch Responders

    //Called when a single tap is detected. It sets the tapped card to active in order it initiate a movement of the card.
    private func touchDown(atPoint point: CGPoint) {
        if gameGraphics.isDiceTapped(point: point) {
            gameGraphics.newDice(to: self)
        }
        guard
            let playingCard = gameGraphics.cardFrom(position: point),
            let parent = playingCard.parent,
            let location = game.location(from: playingCard.card),
            game.canMove(card: playingCard.card)
        
        else {
            return
        }
       
        let touchPoint = playingCard.convert(point, from: parent)
        gameGraphics.setActive(card: playingCard)
        currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: touchPoint, location: location)
        
    }
    
    private func moveDice(atPoint point: CGPoint) {
        if let dice = gameGraphics.findDice(point: point) {
            dice.update(position: point)
        }
    }

    //Updates the position of the card as the card is being dragged
    private func touchMoved(toPoint pos: CGPoint) {
        guard let currentPlayingCard = currentPlayingCard else { return }
        currentPlayingCard.update(position: pos)
    }

    //Called when the mouse is clicked once. It calls the move function when a card has been dragged and released to a new location
    private func touchUp(atPoint pos: CGPoint) {
        guard let currentPlayingCard = currentPlayingCard else { return }
        //Drop location is set as the location where the card is released.
        if let dropLocation = gameGraphics.dropLocation(from: pos, playingCard: currentPlayingCard.playingCard, game: game) {
            do {
                //Updates the model by removing the card from the origonal location and adding it to the new location.
                
                try game.move(card: currentPlayingCard, to: dropLocation)
                //Updates the view by moving the image to the correct animation
                gameGraphics.move(currentPlayingCard: currentPlayingCard, to: dropLocation, gameDecks: game.deck, gameBattleDeck: game.allBattlefields, hand: game.hands)
                gameGraphics.updateCardStack(card: currentPlayingCard, location: currentPlayingCard.location, gameBattleDeck: game.allBattlefields, hand: game.hands)
            } catch GameError.invalidMove {
                currentPlayingCard.returnToOriginalLocation()
                print("Invalid Move")
            } catch {
                // Something went wrong - don't know what
                currentPlayingCard.returnToOriginalLocation()
            }
        } else {
    
            currentPlayingCard.returnToOriginalLocation()
        }
        self.currentPlayingCard = nil

        if game.isGameOver {
            gameIsWon()
        }
        let lengthX = pow((currentPlayingCard.startPosition.x - pos.x), 2)
        let lengthY = pow((currentPlayingCard.startPosition.y - pos.y), 2)
        let length: Bool = (lengthX + lengthY).squareRoot() <  20.0
        if currentPlayingCard.playingCard.heldBy == "Battlefield" && length {
            gameGraphics.tapCard(card: currentPlayingCard.playingCard)
        }
        else if currentPlayingCard.playingCard.heldBy == "Battlefield" {
            updateDatabase(playingCard: currentPlayingCard.playingCard)
        }
        gameGraphics.update(gameDeck: game.deck)
        
    }
    
    //Called when the mouse is clicked twice. It calls the methods to move a card from the deck into the hand
    func doubleTap(at point: CGPoint) {
        let playingCard = gameGraphics.cardFrom(position: point)
        
        if playingCard!.heldBy == "Deck" {
            self.drawCard()
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func drawCard() {
        let card = game.deck.bottomCard
        let playingCard = gameGraphics.findPlayingCard(from: card!)
        guard
            let location = game.location(from: playingCard.card),
            game.canMove(card: playingCard.card)
            
            else { return }
        
        gameGraphics.setActive(card: playingCard)
        currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: playingCard.anchorPoint, location: location)
        let dropLocation = gameGraphics.dropLocation(from: gameGraphics.hands.position, playingCard: currentPlayingCard!.playingCard, game: game)
        do {
            //Updates the model by removing the card from the origonal location and adding it to the new location.
            
            try game.move(card: currentPlayingCard!, to: dropLocation!)
            //Updates the view by moving the image to the correct animation
            gameGraphics.move(currentPlayingCard: currentPlayingCard!, to: dropLocation!, gameDecks: game.deck, gameBattleDeck: game.allBattlefields, hand: game.hands)
            gameGraphics.updateCardStack(card: currentPlayingCard!, location: currentPlayingCard!.location, gameBattleDeck: game.allBattlefields, hand: game.hands)
        } catch GameError.invalidMove {
            currentPlayingCard!.returnToOriginalLocation()
            print("Invalid Move")
        } catch {
            // Something went wrong - don't know what
            currentPlayingCard!.returnToOriginalLocation()
        }
        
        
    self.currentPlayingCard = nil
    
    gameGraphics.update(gameDeck: game.deck)
        
    }
        
        private func requestNewGame() {
            guard let viewDelegate = viewDelegate, viewDelegate.newGame(currentGameState: game.state) else { return }
            newGame()
        }

        private func gameIsWon() {
            //Do something here when the game is finished
            viewDelegate?.gameDone()
        }
}


// MARK: - ViewControllerDegelate
extension GameScene: ViewControllerDelegate {
    var gameState: Game.State {
        return game.state
    }
    

    func newGame() {
        
        game.new()
        gameGraphics.newGame(gameDecks: game.deck)
        gameGraphics.addCards(to: self)
        for _ in 0..<7 {
            drawCard()
            
        }
        
        if let playerName = UserDefaults.standard.string(forKey: "PlayerName") {
            updatePlayer(playerName)
        }
        else {
            print("No Player Name")
        }
        
    }

}
