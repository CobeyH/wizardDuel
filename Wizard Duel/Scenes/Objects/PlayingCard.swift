//
//  PlayingCard.swift
//  Freegraveyard2
//
//  Created by gary on 16/06/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import SpriteKit
#if os(iOS)
import Firebase
#elseif os(OSX)
import FirebaseDatabase
#endif

final class PlayingCard: SKSpriteNode {
    //Holds the filename of the card
    let card: Card
    //Tapped is true when the card is horizantal in the battlefield
    var tapped = false
    //A string indication of where the card currently is
    var heldBy = "Deck"
    var databaseRef: String?

    //Creates a playing card Sprite which is assigned the texture of the back of the card. It inherits its other properties from the card struct
    init(card: Card, size: CGSize, databaseRef: String?) {
        let texture = SKTexture(imageNamed: "cardback.png")
        self.card = card
        self.databaseRef = databaseRef
        
        super.init(texture: texture, color: .clear, size: size)
        self.name = card.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlayingCard {
    static func ==(lhs: PlayingCard, rhs: PlayingCard) -> Bool {
        return lhs.card == rhs.card
    }
}


extension Card {
    var fileName: String {
        return "\(name).full.jpg"
    }
}
