//
//  CascadeTests.swift
//  Freecell2
//
//  Created by gary on 19/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import XCTest
@testable import Freecell2

class CascadeTests: XCTestCase {

    func testCanAddEmpty() {
        let deck = Card.deck()
        for card in deck {
            let cascade = Cascade(cards: [])
            XCTAssertTrue(cascade.canAdd(card: card))
        }
    }


    func testCanAddNotEmptyTrue() {
        let card1 = Card(suit: .diamonds, value: .five)
        let card2 = Card(suit: .clubs, value: .four)
        let card3 = Card(suit: .spades, value: .four)
        let cascade = Cascade(cards: [card1])
        XCTAssertTrue(cascade.canAdd(card: card2))
        XCTAssertTrue(cascade.canAdd(card: card3))
    }


    func testCanAddNotEmptyFalse() {
        let cascadeCard = Card(suit: .diamonds, value: .five)
        let cascade = Cascade(cards: [cascadeCard])
        let testCards: [Card] = [
            Card(suit: .diamonds, value: .four),
            Card(suit: .hearts, value: .four),
            Card(suit: .clubs, value: .five),
            Card(suit: .spades, value: .five)
        ]
        for card in testCards {
            XCTAssertFalse(cascade.canAdd(card: card), card.debugDescription)
        }
    }
}
