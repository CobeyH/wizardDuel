//
//  GraveyardTests.swift
//  Freegraveyard2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import XCTest
@testable import Freegraveyard2

class GraveyardTests: XCTestCase {

    func testExample() {
        let state = State.card(Card(suit: .spades, value: .three))
        let graveyard = Graveyard()
        graveyard.state = state
        XCTAssertTrue(graveyard.canAdd(card: Card(suit: .spades, value: .four)))
        XCTAssertFalse(graveyard.canAdd(card: Card(suit: .spades, value: .three)))
        XCTAssertFalse(graveyard.canAdd(card: Card(suit: .spades, value: .two)))
        XCTAssertFalse(graveyard.canAdd(card: Card(suit: .hearts, value: .four)))
    }
}
