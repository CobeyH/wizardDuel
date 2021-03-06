//
//  CurrentPlayingCard.swift
//  Freegraveyard2
//
//  Created by gary on 19/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Foundation
import SpriteKit

struct CurrentPlayingCard {
    let playingCard: PlayingCard
    let startPosition: CGPoint
    let touchPoint: CGPoint
    let location: Location

    //Used in the dragging of the card to show the consistant movement of the card
    func update(position: CGPoint) {
        playingCard.position = CGPoint(x: position.x - touchPoint.x, y: position.y - touchPoint.y)
    }

    //Deals with the moving of the card and changes the image of the card once it is released
    func move(to position: CGPoint) {
        let action = SKAction.move(to: position, duration: 0.2)
        playingCard.run(action)
        setTexture()
    }
    
    func setTexture() {
        let texture = SKTexture(imageNamed: playingCard.card.fileName)
        playingCard.texture = texture
        
    }

    //Returns the card to the where it started. Used when an invalid move is made and the card must be reset.
    func returnToOriginalLocation() {
        move(to: startPosition)
    }
    
}
