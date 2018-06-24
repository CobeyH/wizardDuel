//
//  PlayerInfo.swift
//  Wizard Duel
//
//  Created by Cobey Hollier on 2018-06-24.
//  Copyright © 2018 Gary Kerr. All rights reserved.
//

import SpriteKit

class PlayerInfo: SKSpriteNode {
    let config = GameGraphicsConfig()
    let playerName: String
    let playerNumber: Int
    var lifeTotal: Int
    var labels: [SKLabelNode] = []
    
    init(lifeTotal: Int, playerName: String, playerNumber: Int, to scene: SKScene) {
        let texture = SKTexture(imageNamed: "4")
        let size = config.playerInfoSize
        self.playerName = playerName
        self.playerNumber = playerNumber
        self.lifeTotal = lifeTotal
        
        super.init(texture: texture, color: .clear, size: size)
        self.anchorPoint = CGPoint(x: 0.5, y: 1)
        self.position = CGPoint(x: config.playerInfoSize.width/2, y: 0)
        scene.addChild(self)
        
        let nameLabel = SKLabelNode()
        let healthLabel = SKLabelNode()
//        let healthUpLabels = SKLabelNode()
//        let healthDownLabel = SKLabelNode()
        labels.append(nameLabel)
        labels.append(healthLabel)
        
        for (i,label) in labels.enumerated() {
            label.fontSize = 25
            label.fontName = "Planewalker"
            label.zPosition = config.zIndex
            label.position = CGPoint(x: 0, y: CGFloat(-(i + 1) * 30))
            self.addChild(label)
        }
        
        
        nameLabel.text = playerName
        healthLabel.text = "40"

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func getLife() -> Int {
        return lifeTotal
    }
    
    func lifeDown() {
        lifeTotal = lifeTotal - 1
    }
    
    func lifeUp() {
        lifeTotal = lifeTotal + 1
    }
    
}
