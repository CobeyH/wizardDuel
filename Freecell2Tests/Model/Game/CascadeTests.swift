//
//  DeckTests.swift
//  Freegraveyard2
//
//  Created by gary on 19/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import XCTest
@testable import Freecell2

class DeckTests: XCTestCase {

    func testCanAddEmpty() {
        let deck = Card.deck()
        for card in deck {
            let deck = Deck(cards: [])
            XCTAssertTrue(deck.canAdd(card: card))
        }
    }


    func testCanAddNotEmptyTrue() {
        let card1 = Card(suit: .diamonds, value: .five)
        let card2 = Card(suit: .clubs, value: .four)
        let card3 = Card(suit: .spades, value: .four)
        let deck = Deck(cards: [card1])
        XCTAssertTrue(deck.canAdd(card: card2))
        XCTAssertTrue(deck.canAdd(card: card3))
    }


    func testCanAddNotEmptyFalse() {
        let deckCard = Card(suit: .diamonds, value: .five)
        let deck = Deck(cards: [deckCard])
        let testCards: [Card] = [
            Card(suit: .diamonds, value: .four),
            Card(suit: .hearts, value: .four),
            Card(suit: .clubs, value: .five),
            Card(suit: .spades, value: .five)
        ]
        for card in testCards {
            XCTAssertFalse(deck.canAdd(card: card), card.debugDescription)
        }
    }
}
