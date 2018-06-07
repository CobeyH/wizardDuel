//
//  Dice.swift
//  Wizard Duel
//
//  Created by Cobey Hollier on 2018-06-05.
//  Copyright © 2018 Gary Kerr. All rights reserved.
//

import Foundation
import SpriteKit

class Dice {
    var value = 1
    let maxValue: Int
    
    init(maxValue: Int) {
        self.maxValue = maxValue
    }
    
    func diceUp() {
        value += 1
        if value > maxValue {
            value = 1
        }
    }
    func diceDown() {
        value -= 1
        if value < 1 {
            value = 0
        }
    }
    
}
