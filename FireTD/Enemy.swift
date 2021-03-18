//
//  Enemy.swift
//  FireTD
//
//  Created by LANCASTER, TRISTAN on 24/11/2019.
//  Copyright © 2019 LANCASTER, TRISTAN. All rights reserved.
//

import SpriteKit

class Enemy: SKSpriteNode {
    var stats: EnemyStats
    var currentHealth: Int
    var onFire: Bool
    var fireLevel: Int {
        didSet {
            guard stats.flammable else { return }
            lastFireTick = lastUpdateTick
            guard fireLevel > 0 else {
                onFire = false
                return
            }
            onFire = true
            if let flame = SKEmitterNode(fileNamed: "Flame\(fireLevel)") {
                addChild(flame)
                flame.zRotation = -self.zRotation
                let sequence = SKAction.sequence([SKAction.wait(forDuration: 5), .removeFromParent()])
                flame.run(sequence)
            }
        }
    }
    var lastFireTick: Double
    var lastUpdateTick: Double
    
    init(statistics: EnemyStats) {
        self.stats = statistics
        currentHealth = statistics.maxHealth
        onFire = false
        fireLevel = 0
        lastFireTick = 0
        lastUpdateTick = 0
        
        let texture = SKTexture(imageNamed: statistics.sprite)
        super.init(texture: texture, color: .white, size: texture.size())
        
        physicsBody = SKPhysicsBody(circleOfRadius: abs(texture.size().width / 2 - 5))
        physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = CollisionType.towerProjectile.rawValue | CollisionType.ball.rawValue | CollisionType.fire.rawValue | CollisionType.end.rawValue
        physicsBody?.affectedByGravity = false
        
        zRotation = .pi
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Nope")
    }
    
    func damage(amount: Int) -> Bool {
        guard currentHealth > 0 else { return false }
        currentHealth -= amount
        if currentHealth < 1 {
            //Die
            removeAction(forKey: "alive")
            let sequence = SKAction.sequence([SKAction.fadeAlpha(to: 0.25, duration: 0.5), SKAction.fadeAlpha(to: 0, duration: 4), .removeFromParent()])
            physicsBody?.categoryBitMask = CollisionType.dieing.rawValue
            physicsBody?.collisionBitMask = 0
            physicsBody?.contactTestBitMask = 0
            fireLevel = 0
            for node in children {
                node.removeFromParent()
            }
            run(sequence)
            if let deathExplosion = SKEmitterNode(fileNamed: "Death") {
                deathExplosion.position = position
                parent?.addChild(deathExplosion)
                let sequence = SKAction.sequence([SKAction.wait(forDuration: 2), .removeFromParent()])
                deathExplosion.run(sequence)
            }
            return true
        } else if currentHealth > stats.maxHealth {
            currentHealth = stats.maxHealth
        }
        return false
    }
    
    func burn(time: Double) -> Bool {
        //Rotate flame animations to screen
        for particle in children {
            particle.zRotation = -self.zRotation
        }
        lastUpdateTick = time
        guard stats.flammable else { return false }
        guard onFire else { return false }
        guard lastFireTick + 2 < time else { return false }
        
        fireLevel = fireLevel - 1
        return damage(amount: 1)
    }
    
}
