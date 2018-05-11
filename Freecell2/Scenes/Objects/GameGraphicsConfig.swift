//
//  GameGraphicsConfig.swift
//  Freecell2
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
    let margin: CGFloat = -40
    var zIndex: CGFloat = 10
    let zIndexIncrement: CGFloat = 5

    let backgroundColour = NSColor.init(white: 1.0, alpha: 0.2)

    let cellCount = 4
    let foundationCount = 4
    let cascadeCount = 8


    mutating func getZIndex() -> CGFloat {
        zIndex += zIndexIncrement
        return zIndex
    }
}
