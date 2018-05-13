//
//  FoundationTests.swift
//  Freecell2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import XCTest
@testable import Freecell2

class FoundationTests: XCTestCase {

    func testExample() {
        let state = State.card(Card(suit: .spades, value: .three))
        let foundation = Foundation()
        foundation.state = state
        XCTAssertTrue(foundation.canAdd(card: Card(suit: .spades, value: .four)))
        XCTAssertFalse(foundation.canAdd(card: Card(suit: .spades, value: .three)))
        XCTAssertFalse(foundation.canAdd(card: Card(suit: .spades, value: .two)))
        XCTAssertFalse(foundation.canAdd(card: Card(suit: .hearts, value: .four)))
    }
}
