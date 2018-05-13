//
//  PlayingCard.swift
//  Freecell2
//
//  Created by gary on 16/06/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import SpriteKit

final class PlayingCard: SKSpriteNode {

    let card: Card
    var faceUp: Bool = false

    //What I don't understand
    //PlayingCard is a subclass of SKSpriteNode that holds a card and the name of that card. I have set it to start face down but do not know how to change of texture
    //at a later time. I don't know what object to access to change the texture of the desired playing card.
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



//extension Value {
//    var fileName: String {
//        switch self {
//        case .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten:
//            return String(describing: self.rawValue)
//        case .ace:
//            return "ace"
//        case .jack:
//            return "jack"
//        case .queen:
//            return "queen"
//        case .king:
//            return "king"
//        }
//    }
//}
//
//
//extension Suit {
//    var fileName: String {
//        switch self {
//        case .clubs:
//            return "clubs"
//        case .diamonds:
//            return "diamonds"
//        case .hearts:
//            return "hearts"
//        case .spades:
//            return "spades"
//        }
//    }
//}
