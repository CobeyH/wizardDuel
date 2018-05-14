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
        gameGraphics.setupCards(gameDecks: game.decks)
        gameGraphics.addChildren(to: self)

        gameGraphics.setupBackground(to: self)
    }


    override func mouseDown(with event: NSEvent) {
//        if (event.clickCount == 2) {
//            doubleClick(at: event.location(in: self))
//        } else {
            touchDown(atPoint: event.location(in: self))
//        }
    }


    override func mouseDragged(with event: NSEvent) {
        touchMoved(toPoint: event.location(in: self))
    }


    override func mouseUp(with event: NSEvent) {
        touchUp(atPoint: event.location(in: self))
    }


    // MARK: - Touch graveyardlers

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
    }


//    private func doubleClick(at point: CGPoint) {
//        guard
//            let playingCard = gameGraphics.cardFrom(position: point),
//            let location = game.location(from: playingCard.card),
//            game.canMove(card: playingCard.card)
//        else {
//            return
//        }
//
//        let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: point, touchPoint: point, location: location)
//
//        do {
//            let newLocation = try game.quickMove(from: location)
//            gameGraphics.move(currentPlayingCard: currentPlayingCard, to: newLocation, gameDecks: game.decks)
//        } catch {}
//
//        if game.isGameOver {
//            gameIsWon()
//        }
//    }


    private func touchMoved(toPoint pos: CGPoint) {
        guard let currentPlayingCard = currentPlayingCard else { return }
        currentPlayingCard.update(position: pos)
    }


    private func touchUp(atPoint pos: CGPoint) {
        guard let currentPlayingCard = currentPlayingCard else { return }
        if let dropLocation = gameGraphics.dropLocation(from: pos, currentPlayingCard: currentPlayingCard, game: game) {
            do {
                let startLocation = currentPlayingCard.location
                try game.move(from: startLocation, to: dropLocation)
                gameGraphics.move(currentPlayingCard: currentPlayingCard, to: dropLocation, gameDecks: game.decks)
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
        gameGraphics.newGame(gameDecks: game.decks)
        gameGraphics.addCards(to: self)
    }


    func undo() {
        guard let move = game.lastMove else { return }
        // game undo should return Card
        guard let card = game.undo(move: move) else { return }
        // pass card name to graphics so it can easily find node from name
        // construct CurrentPlayingCard to pass into this method
        gameGraphics.undo(move: move, card: card, gameDecks: game.decks)
    }
}
