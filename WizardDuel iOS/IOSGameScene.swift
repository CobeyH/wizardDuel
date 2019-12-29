//
//  IOSGameScene.swift
//  WizardDuel iOS
//
//  Created by Cobey Hollier on 2018-09-09.
//  Copyright © 2018 Gary Kerr. All rights reserved.
//
import UIKit

extension GameScene {
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
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        let locationInView = sender.location(in: view)
        if let locationInScene = view?.convert(locationInView, to:scene!) {
            gameGraphics.showPlayingCard(at: locationInScene, scene: self)
        }
        if sender.state == UIGestureRecognizer.State.ended {
            gameGraphics.hideCardDisplay()
        }
    }
    
}
