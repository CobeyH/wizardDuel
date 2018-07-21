//
//  GameGraphicsConfig.swift
//  Freehand2
//
//  Created by gary on 31/08/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import Foundation
import SpriteKit

#if os(iOS)
public typealias Color = UIColor
#elseif os(OSX)
public typealias Color = NSColor
#endif

struct GameGraphicsConfig {
    let cardSize: CGSize
    let offsetX: CGFloat
    let offsetY: CGFloat
    let margin: CGFloat
    let playerInfoSize: CGSize
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let diceSizeFinal: CGSize
    let cardOffset: CGFloat
    let battlefieldSpacing: CGFloat
    let spacing: CGFloat
    
    let diceSizeInitial = CGSize(width: 70, height: 70)
    let cardMiddle = CGPoint(x: 0.5, y: 0.5)
    var zIndex: CGFloat = 10
    let zIndexIncrement: CGFloat = 2
    let backgroundName =  "background1.jpg"
    let backgroundColour: Color
    let battlefieldColour: Color
    let cardbackName = "cardback.png"
    let numberOfBackgrounds = 2
    let graveyardCount = 3
    let backgroundCount = 2
    
    //Initializes all of the sizes to be consistant on all of the devices.
    init() {
        #if os(iOS)
        let frame = UIScreen.main.bounds
        #elseif os(OSX)
        let frame = NSScreen.main?.frame ?? CGRect.zero
        #endif
        let rect = frame.size
        self.screenWidth = rect.width
        self.screenHeight = rect.height
        let height = rect.height / 7.5
        let width = height * 0.7147
        self.cardSize = CGSize(width: width, height: height)
        self.offsetX = CGFloat(width/2)
        self.offsetY = -CGFloat(height/2)
        self.spacing = rect.height/100
        self.battlefieldSpacing = rect.height/200
        self.margin = -rect.width/60
        self.playerInfoSize = CGSize(width: rect.width / 19, height: rect.height / 7.5)
        self.diceSizeFinal = CGSize(width: rect.width/30, height: rect.width/30)
        self.cardOffset = cardSize.height/8.75
        
        backgroundColour = Color.init(white: 1.0, alpha: 0.2)
        battlefieldColour = Color.init(white: 1.0, alpha: 0.05)
    }


    mutating func getZIndex() -> CGFloat {
        zIndex += zIndexIncrement
        return zIndex
    }
    
    func getScale() -> (CGFloat,CGFloat) {
        return (screenWidth * 0.00075, screenHeight * 0.001)
    }
}
