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
    let cardSize: CGSize
    let offsetX: CGFloat
    let offsetY: CGFloat
    
    let diceSize = CGSize(width: 40, height: 40)
    
    let spacing: CGFloat = 20
    let battlefierdSpacing: CGFloat = 16
    let margin: CGFloat = -40
    var zIndex: CGFloat = 10
    let zIndexIncrement: CGFloat = 2

    let backgroundName =  "background1"
    let backgroundColour = NSColor.init(white: 1.0, alpha: 0.2)
    let battlefieldColour = NSColor.init(white: 1.0, alpha: 0.05)
    let numberOfBackgrounds = 2

    let graveyardCount = 3
    
    init() {
        let width = 96.956
        let height = 134.78
        cardSize = CGSize(width: width, height: height)
        offsetX = CGFloat(width/2)
        offsetY = -CGFloat(height/2)
    }


    mutating func getZIndex() -> CGFloat {
        zIndex += zIndexIncrement
        return zIndex
    }
}
