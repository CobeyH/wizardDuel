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
    let cardMiddle = CGPoint(x: 0.5, y: 0.5)
    let cardSize = CGSize(width: 96.956, height: 134.78)
    let offsetX = CGFloat(96.956/2)
    let offsetY = -CGFloat(134.78/2)
    
    let spacing: CGFloat = 20
    let battlefierdSpacing: CGFloat = 16
    let margin: CGFloat = -40
    var zIndex: CGFloat = 10
    let zIndexIncrement: CGFloat = 5

    let backgroundName =  "background1"
    let backgroundColour = NSColor.init(white: 1.0, alpha: 0.2)
    let battlefieldColour = NSColor.init(white: 1.0, alpha: 0.05)
    let numberOfBackgrounds = 2

    let graveyardCount = 2
    


    mutating func getZIndex() -> CGFloat {
        zIndex += zIndexIncrement
        return zIndex
    }
}
