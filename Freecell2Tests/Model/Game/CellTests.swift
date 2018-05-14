//
//  HandTests.swift
//  Freegraveyard2
//
//  Created by gary on 19/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import XCTest
@testable import Freegraveyard2

class HandTests: XCTestCase {

    func testCanAddEmpty() {
        for card in Card.deck() {
            let graveyard = Hand()
            XCTAssertTrue(graveyard.canAdd(card: card))
        }
    }


    func testCanAddNotEmpty() {
        let testCard = Card(suit: .clubs, value: .ace)
        for card in Card.deck() {
            let graveyard = Hand()
            try! graveyard.add(card: testCard)
            XCTAssertFalse(graveyard.canAdd(card: card))
        }
    }
}
