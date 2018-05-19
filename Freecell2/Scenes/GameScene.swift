//
//  GameScene.swift
//  Freegraveyard2
//
//  Created by gary on 16/06/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    // MARK: - Properties

    private let game = Game()
    private var gameGraphics = GameGraphics()
    private let endAnimation: EndAnimationProtocol = StandardEndAnimation()
    private var currentPlayingCard: CurrentPlayingCard?
    weak var viewDelegate: GameSceneDelegate?

    // MARK: - Lifecycle
    override func sceneDidLoad() {
        super.sceneDidLoad()
        anchorPoint = CGPoint(x: 0, y: 1)
    }

    override func didMove(to view: SKView) {
        // https://stackoverflow.com/questions/39590602/scenedidload-being-called-twice
        super.didMove(to: view)
        self.size = view.bounds.size
        gameGraphics.setup(width: size.width, height: size.height)
        gameGraphics.setupCards(gameDecks: game.deck)
        gameGraphics.addChildren(to: self)
        gameGraphics.setupBackground(to: self)
    }

    // MARK: - Action Triggers
    //Triggered when the mouse is pressed down. It is only used to call other methods depending on the number of clicks
    override func mouseDown(with event: NSEvent) {
        if (event.clickCount == 2) {
            doubleTap(at: event.location(in: self))
        } else {
            touchDown(atPoint: event.location(in: self))
        }
    }

    //Triggers on mouse dragging
    override func mouseDragged(with event: NSEvent) {
        touchMoved(toPoint: event.location(in: self))
    }

    //Triggers when the mouse is released
    override func mouseUp(with event: NSEvent) {
        touchUp(atPoint: event.location(in: self))
    }

    
    // MARK: - Touch Responders

    //Called when a single tap is detected. It taps the clicked card if it is on the battlefield
    private func touchDown(atPoint point: CGPoint) {

        if gameGraphics.isNewGameTapped(point: point) {
            requestNewGame()
            return
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
        if playingCard.heldBy == "Battlefield" {
            gameGraphics.tapCard(card: playingCard)
            
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
                gameGraphics.move(currentPlayingCard: currentPlayingCard, to: dropLocation, gameDecks: game.deck, gameBattleDeck: game.battlefieldCells, hand: game.hands)
                gameGraphics.updateCardStack(card: currentPlayingCard, gameBattleDeck: game.battlefieldCells, hand: game.hands)
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
    }
    
    //Called when the mouse is clicked twice. It calls the methods to move a card from the deck into the hand
    func doubleTap(at point: CGPoint) {
        guard
            let playingCard = gameGraphics.cardFrom(position: point),
            let location = game.location(from: playingCard.card),
            game.canMove(card: playingCard.card)
            else {
                return
        }
        
        let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: point, touchPoint: point, location: location)
        
        do {
            try game.move(card: currentPlayingCard, to: Location.hand())
            
        }catch {}
        gameGraphics.move(currentPlayingCard: currentPlayingCard, to: Location.hand(), gameDecks: game.deck, gameBattleDeck: game.battlefieldCells, hand: game.hands)
        gameGraphics.updateCardStack(card: currentPlayingCard, gameBattleDeck: game.battlefieldCells, hand: game.hands)
    }
    
    private func requestNewGame() {
        guard let viewDelegate = viewDelegate, viewDelegate.newGame(currentGameState: game.state) else { return }
        newGame()
    }

    private func gameIsWon() {
        endAnimation.run(with: gameGraphics.cards, and: self)
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
    }

}
