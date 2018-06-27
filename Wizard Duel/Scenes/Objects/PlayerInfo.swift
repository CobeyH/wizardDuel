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
        scene.addChild(self)
        
        let nameLabel = SKLabelNode()
        let healthLabel = SKLabelNode()
        let healthUpLabel = SKLabelNode()
        let healthDownLabel = SKLabelNode()
        labels.append(nameLabel)
        labels.append(healthLabel)
        labels.append(healthUpLabel)
        labels.append(healthDownLabel)
        
        for (i,label) in labels.enumerated() {
            label.fontSize = 25
            label.fontName = "Planewalker"
            label.zPosition = config.zIndex
            label.position = CGPoint(x: 0, y: CGFloat(-(i + 1) * 30))
            self.addChild(label)
        }
        
        
        nameLabel.text = playerName
        healthLabel.text = "40"
        healthUpLabel.text = "+"
        healthDownLabel.text = "-"

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func movePlayerInfo(playerNumberSelf: Int) {
        let infoLocations = [CGPoint(x: config.playerInfoSize.width/2, y: -config.screenHeight/2 + config.playerInfoSize.height/2) ,CGPoint(x: config.playerInfoSize.width/2, y: 0), CGPoint(x: config.screenWidth - config.playerInfoSize.width/2, y: 0), CGPoint(x: config.screenWidth - config.playerInfoSize.width/2, y: -config.screenHeight/2 + config.playerInfoSize.height/2)]
        self.position = infoLocations[(4 + Int(playerNumber) - playerNumberSelf) % 4]
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
