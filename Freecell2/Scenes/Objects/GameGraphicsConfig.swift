//
//  GameGraphicsConfig.swift
//  Freehand2
//
//  Created by gary on 31/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Foundation
import Cocoa

struct GameGraphicsConfig {
    let topLeft = CGPoint(x: 0, y: 1)
    let cardSize = CGSize(width: 103, height: 150)
    let spacing: CGFloat = 20
    let battlefierdSpacing: CGFloat = 16
    let margin: CGFloat = -40
    var zIndex: CGFloat = 10
    let zIndexIncrement: CGFloat = 5

    let backgroundName =  "2"
    let backgroundColour = NSColor.init(white: 1.0, alpha: 0.2)
    let battlefieldColour = NSColor.init(white: 1.0, alpha: 0.05)

    let handCount = 1
    let graveyardCount = 2
    let deckCount = 1


    mutating func getZIndex() -> CGFloat {
        zIndex += zIndexIncrement
        return zIndex
    }
}
