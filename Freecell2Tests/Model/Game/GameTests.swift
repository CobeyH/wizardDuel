//
//  GameTests.swift
//  Freegraveyard2
//
//  Created by gary on 15/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import XCTest
@testable import Freegraveyard2

class GameTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }


    func testCard() {
        let card = Card(suit: .clubs, value: .three)
        print(card)
    }


    func testDeckFilenames() {
        for card in Card.deck() {
            print(card.fileName)
        }
    }

    func testGame() {
        let game = Game()
        print(game)
    }
}
