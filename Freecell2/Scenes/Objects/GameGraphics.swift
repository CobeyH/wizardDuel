//
//  GameGraphics.swift
//  Freecell2
//
//  Created by gary on 31/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import SpriteKit

struct GameGraphics {

    private var config = GameGraphicsConfig()

    private var cells: [SKSpriteNode] = []
    private var foundations: [SKSpriteNode] = []
    private var cascades: [SKSpriteNode] = []
    private var newGameButton: SKSpriteNode = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))

    var cards: [PlayingCard] = []

    mutating func setup(width: CGFloat) {
        let baseZPosition: CGFloat = config.zIndexIncrement

        // Cells
        for i in 0 ..< config.cellCount {
            let cell = SKSpriteNode(color: config.backgroundColour, size: config.cardSize)
            cell.anchorPoint = config.topLeft
            cell.position = CGPoint(x: -config.margin + CGFloat(i) * (config.cardSize.width + config.spacing), y: config.margin)
            cell.zPosition = baseZPosition
            cells.append(cell)
        }

        // Foundations
        for i in 0 ..< config.foundationCount {
            let foundation = SKSpriteNode(color: config.backgroundColour, size: config.cardSize)
            foundation.anchorPoint = config.topLeft
            foundation.position = CGPoint(x: width + config.margin - config.cardSize.width - CGFloat(i) * (config.cardSize.width + config.spacing), y: config.margin)
            foundation.zPosition = baseZPosition
            foundations.append(foundation)
        }

        let cascadeWidth = CGFloat(config.cascadeCount) * config.cardSize.width + CGFloat(config.cascadeCount - 1) * config.spacing
        let cascadeMargin = (width - cascadeWidth) / 2

        // Cascades
        for i in 0 ..< config.cascadeCount {
            let cascade = SKSpriteNode(color: config.backgroundColour, size: config.cardSize)
            cascade.anchorPoint = config.topLeft
            cascade.position = CGPoint(x: cascadeMargin + CGFloat(i) * (config.cardSize.width + config.spacing), y: 2 * config.margin - config.cardSize.height)
            cascade.zPosition = baseZPosition
            cascades.append(cascade)
        }

        // New game button
        newGameButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        newGameButton.position = CGPoint(x: width / 2, y: -110)
        newGameButton.zPosition = baseZPosition
    }


    mutating func setupCards(gameCascades: [Cascade]) {
        // Playing cards
        for (cascadeCards, cascade) in zip(gameCascades, cascades) {
            let cascadePosition = cascade.position
            for (i, gameCard) in cascadeCards.cards.enumerated() {
                let card = PlayingCard(card: gameCard, size: config.cardSize)
                card.anchorPoint = config.topLeft
                card.size = config.cardSize
                card.position = CGPoint(x: cascadePosition.x, y: cascadePosition.y + config.margin * CGFloat(i))
                card.zPosition = config.getZIndex()
                cards.append(card)
            }
        }
    }


    func addChildren(to scene: SKScene) {
        for cell in cells {
            scene.addChild(cell)
        }
        for foundation in foundations {
            scene.addChild(foundation)
        }
        for cascade in cascades {
            scene.addChild(cascade)
        }
        addCards(to: scene)
        scene.addChild(newGameButton)
    }


    func addCards(to scene: SKScene) {
        for card in cards {
            scene.addChild(card)
        }
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


    mutating func newGame(gameCascades: [Cascade]) {
        for card in cards {
            card.removeFromParent()
        }
        cards = []
        setupCards(gameCascades: gameCascades)
    }


    func move(currentPlayingCard: CurrentPlayingCard, to location: Location, gameCascades: [Cascade]) {
        let newPosition: CGPoint
        switch location {
        case .cell(let value):
            let cell = cells[value]
            newPosition = cell.position
        case .foundation(let value):
            let foundation = foundations[value]
            newPosition = foundation.position
        case .cascade(let value):
            let cascade = cascades[value]
            let gameCascade = gameCascades[value]
            let cardCount = gameCascade.cards.count - 1
            let cascadePosition = cascade.position
            newPosition = CGPoint(x: cascadePosition.x, y: cascadePosition.y + CGFloat(cardCount) * config.margin)
        }
        currentPlayingCard.move(to: newPosition)
    }


    func dropLocation(from position: CGPoint, currentPlayingCard: CurrentPlayingCard, game: Game) -> Location? {
        for (i, cell) in cells.enumerated() {
            if cell.contains(position) {
                return .cell(i)
            }
        }
        for (i, foundation) in foundations.enumerated() {
            if foundation.contains(position) {
                return .foundation(i)
            }
        }
        for playingCard in cards {
            if playingCard == currentPlayingCard.playingCard { continue }
            if playingCard.contains(position) {
                if let location = game.location(from: playingCard.card) {
                    switch location {
                    case .cascade(let value):
                        let cascade = game.cascades[value]
                        if cascade.isBottom(card: playingCard.card) {
                            return location
                        }
                    default:
                        break
                    }
                }
            }
        }
        for (i, cascade) in cascades.enumerated() {
            if cascade.contains(position) {
                let gameCascade = game.cascades[i]
                if gameCascade.isEmpty {
                    return .cascade(i)
                }
            }
        }
        return nil
    }


    func undo(move: Move, card: Card, gameCascades: [Cascade]) {
        print("game graphics, undo", move)
        let position = positionFrom(location: move.toLocation)
        print(position)
        let playingCard = findPlayingCard(from: card)
        let currentPlayingCard = CurrentPlayingCard(playingCard: playingCard, startPosition: playingCard.position, touchPoint: playingCard.position, location: move.toLocation)
        self.move(currentPlayingCard: currentPlayingCard, to: move.fromLocation, gameCascades: gameCascades)
    }


    // MARK: - Private

    private func positionFrom(location: Location) -> CGPoint {
        let position: CGPoint
        switch location {
        case .cascade(let value):
            let cascade = cascades[value]
            print("cascade position")
            position = cascade.position
        case .cell(let value):
            let cell = cells[value]
            print("cell position")
            position = cell.position
        case .foundation(let value):
            let foundation = foundations[value]
            print("foundation position")
            position = foundation.position
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
