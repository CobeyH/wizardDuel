//
//  PlayingCard.swift
//  Freegraveyard2
//
//  Created by gary on 16/06/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import SpriteKit

final class PlayingCard: SKSpriteNode {

    let card: Card
    var faceUp: Bool = false

    //Creates a playing card Sprite which is assigned the texture of the back of the card. It inherits its other properties from the card struct
    init(card: Card, size: CGSize) {
        let texture = SKTexture(imageNamed: "cardback")
        self.card = card
        super.init(texture: texture, color: .clear, size: size)
        self.name = card.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//extension PlayingCard {
//    static func ==(lhs: PlayingCard, rhs: PlayingCard) -> Bool {
//        return lhs.card == rhs.card
//    }
//}


extension Card {
    var fileName: String {
        return "\(name).full.jpg"
    }
}
