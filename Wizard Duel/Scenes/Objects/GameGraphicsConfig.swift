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


public var config: GameGraphicsConfig = {
    return GameGraphicsConfig()
}()

 public struct GameGraphicsConfig {
   
    let cardSize: CGSize
    let offsetX: CGFloat
    let offsetY: CGFloat
    let margin: CGFloat
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let diceSizeFinal: CGSize
    let cardOffset: CGFloat
    let battlefieldSpacing: CGFloat
    let spacing: CGFloat
    let backgroundColour: Color
    let battlefieldColour: Color
    
    let diceSizeInitial = CGSize(width: 70, height: 70)
    let cardMiddle = CGPoint(x: 0.5, y: 0.5)
    var zIndex: CGFloat = 10
    var backgroundIndex = 0
    let zIndexIncrement: CGFloat = 2
    let backgroundName =  "background2.jpg"
    let cardbackName = "cardback.png"
    let numberOfBackgrounds = 2
    let graveyardCount = 3
    let backgroundCount = 5
    
    //Initializes all of the sizes to be consistant on all of the devices.
    init() {
        #if os(iOS)
        let screenBounds = UIScreen.main.bounds
        #elseif os(OSX)
        let screenBounds = NSScreen.main?.frame ?? CGRect.zero
        #endif
        let screenSize = screenBounds.size
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        var height = screenSize.height / 7.5
        var width = screenSize.width / 17
        if width/height < 0.7147 {
            height = width / 0.7147
        } else {
            width = height * 0.7147
        }
        self.cardSize = CGSize(width: width, height: height)
        self.offsetX = CGFloat(width/2)
        self.offsetY = -CGFloat(height/2)
        self.spacing = screenSize.height/100
        self.battlefieldSpacing = screenSize.height/200
        self.margin = -screenSize.width/60
        self.diceSizeFinal = CGSize(width: screenSize.width/30, height: screenSize.width/30)
        self.cardOffset = cardSize.height/8.75
        
        backgroundColour = Color.init(white: 1.0, alpha: 0.2)
        battlefieldColour = Color.init(white: 1.0, alpha: 0.05)
    }

    mutating func getZIndex() -> CGFloat {
        zIndex += zIndexIncrement
        return zIndex
    }
    
    mutating func getBackground() -> String {
        backgroundIndex += 1
        return "background\(backgroundIndex % backgroundCount + 1).jpg"
    }
    
    func getScale() -> (CGFloat,CGFloat) {
        return (screenWidth * 0.00075, screenHeight * 0.001)
    }
}
