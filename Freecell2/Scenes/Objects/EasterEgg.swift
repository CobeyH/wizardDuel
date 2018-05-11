//
//  EasterEgg.swift
//  Freecell2
//
//  Created by gary on 02/09/2017.
//  Copyright © 2017 Gary Kerr. All rights reserved.
//

import SpriteKit

struct EasterEgg {
    
    private let button = SKSpriteNode(color: .clear, size: CGSize(width: 30, height: 30))


    func addChildren(to scene: SKScene) {
        button.anchorPoint = CGPoint(x: 0, y: 1)
        button.position = CGPoint(x: 0, y: 0)
        scene.addChild(button)
    }


    func isEasterEgg(point: CGPoint) -> Bool {
        return button.contains(point)
    }
}
