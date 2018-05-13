//
//  CellTests.swift
//  Freecell2
//
//  Created by gary on 19/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import XCTest
@testable import Freecell2

class CellTests: XCTestCase {

    func testCanAddEmpty() {
        for card in Card.deck() {
            let cell = Cell()
            XCTAssertTrue(cell.canAdd(card: card))
        }
    }


    func testCanAddNotEmpty() {
        let testCard = Card(suit: .clubs, value: .ace)
        for card in Card.deck() {
            let cell = Cell()
            try! cell.add(card: testCard)
            XCTAssertFalse(cell.canAdd(card: card))
        }
    }
}
