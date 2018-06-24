//
//  GameGraphicsConfig.swift
//  Freehand2
//
//  Created by gary on 31/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Foundation
import Cocoa
import SpriteKit


struct GameGraphicsConfig {
    
    
    let cardSize: CGSize
    let offsetX: CGFloat
    let offsetY: CGFloat
    let margin: CGFloat
    
    let diceSize = CGSize(width: 40, height: 40)
    let cardMiddle = CGPoint(x: 0.5, y: 0.5)
    let spacing: CGFloat
    let battlefieldSpacing: CGFloat = 16
    var zIndex: CGFloat = 10
    let zIndexIncrement: CGFloat = 2
    let backgroundName =  "background1"
    let backgroundColour = NSColor.init(white: 1.0, alpha: 0.2)
    let battlefieldColour = NSColor.init(white: 1.0, alpha: 0.05)
    let numberOfBackgrounds = 2

    let graveyardCount = 3
    
    init() {
        let frame = NSScreen.main?.frame ?? CGRect.zero
        let rect = frame
        let height = rect.size.height / 7.5
        let width = rect.size.width / 17.5
        self.cardSize = CGSize(width: width, height: height)
        self.offsetX = CGFloat(width/2)
        self.offsetY = -CGFloat(height/2)
        self.spacing = rect.size.height/100
        self.margin = -rect.size.width/60
        
    }


    mutating func getZIndex() -> CGFloat {
        zIndex += zIndexIncrement
        return zIndex
    }
}
