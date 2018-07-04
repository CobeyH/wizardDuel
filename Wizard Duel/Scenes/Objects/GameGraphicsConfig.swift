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
    let playerInfoSize: CGSize
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    let diceSizeInitial = CGSize(width: 70, height: 70)
    let diceSizeFinal = CGSize(width: 35, height: 35)
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
        let rect = frame.size
        self.screenWidth = rect.width
        self.screenHeight = rect.height
        let height = rect.height / 7.5
        let width = rect.width / 17.5
        self.cardSize = CGSize(width: width, height: height)
        self.offsetX = CGFloat(width/2)
        self.offsetY = -CGFloat(height/2)
        self.spacing = rect.height/100
        self.margin = -rect.width/60
        self.playerInfoSize = CGSize(width: rect.width / 19, height: rect.height / 7.5)
        
    }


    mutating func getZIndex() -> CGFloat {
        zIndex += zIndexIncrement
        return zIndex
    }
}
