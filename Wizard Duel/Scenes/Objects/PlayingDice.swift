//
//  PlayingDice.swift
//  Wizard Duel
//
//  Created by Cobey Hollier on 2018-06-06.
//  Copyright © 2018 Gary Kerr. All rights reserved.
//

import SpriteKit

final class PlayingDice: SKSpriteNode {
    //Holds the filename of the card
    let dice: Dice

    
    //Creates a playing card Sprite which is assigned the texture of the back of the card. It inherits its other properties from the card struct
    init(dice: Dice, size: CGSize) {
        let texture = SKTexture(imageNamed: "dice1")
        self.dice = dice
        super.init(texture: texture, color: .clear, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Used in the dragging of the card to show the consistant movement of the card
    func update(position: CGPoint) {
        self.position = CGPoint(x: position.x, y: position.y)
    }
    
    //Deals with the moving of the card and changes the image of the card once it is released
    func move(to position: CGPoint) {
        let action = SKAction.move(to: position, duration: 0.2)
        self.run(action)
        setTexture()
    }
    
    func setTexture() {
        let texture = SKTexture(imageNamed: "dice\(dice.value)")
        self.texture = texture
        
    }
    
}

