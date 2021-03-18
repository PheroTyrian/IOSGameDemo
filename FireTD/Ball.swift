//
//  Ball.swift
//  FireTD
//
//  Created by LANCASTER, TRISTAN on 25/11/2019.
//  Copyright © 2019 LANCASTER, TRISTAN. All rights reserved.
//

import SpriteKit

enum MoveStates: UInt32 {
    case flier = 0
    case ball = 1
    case tower = 2
}

struct BallStats: Codable {
    let sprite: String
    let description: String
    let cost: Int
    let maxHits: Int
    let flammable: Bool
    let density: Float
    let deathType: Int
}

class Ball: SKSpriteNode {
    let stats: BallStats
    var lifetime: Double
    var turretAngle: CGFloat {
        didSet {
            for node in children {
                let rotation = SKAction.rotate(toAngle: turretAngle, duration: 0.2, shortestUnitArc: true)
                node.run(rotation)
            }
        }
    }
    var targetInRange: Bool
    var hits: Int {
        didSet {
            if (hits <= 0) {
            onDeath()
            }
        }
    }
    var fireLevel : Int {
        didSet {
            guard stats.flammable else { return }
            guard fireLevel > 0 else { return }
            if let flame = SKEmitterNode(fileNamed: "Flame\(fireLevel)") {
                addChild(flame)
                let sequence = SKAction.sequence([SKAction.wait(forDuration: 5), .removeFromParent()])
                flame.run(sequence)
            }
        }
    }
    var lastFireTick : Double
    var moveState: MoveStates {
        didSet {
            //State change code here
            switch (moveState){
            case MoveStates.flier:
                physicsBody?.categoryBitMask = CollisionType.flier.rawValue
                physicsBody?.collisionBitMask = 0
                physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
                physicsBody?.allowsRotation = false
                physicsBody?.isDynamic = true
                break
            case MoveStates.ball:
                physicsBody?.categoryBitMask = CollisionType.ball.rawValue
                physicsBody?.collisionBitMask = CollisionType.tower.rawValue | CollisionType.ball.rawValue | CollisionType.end.rawValue | CollisionType.wall.rawValue | CollisionType.flier.rawValue
                physicsBody?.contactTestBitMask = CollisionType.fire.rawValue | CollisionType.ball.rawValue | CollisionType.enemy.rawValue
                physicsBody?.allowsRotation = false
                physicsBody?.isDynamic = true
                physicsBody?.linearDamping = 0.4
                physicsBody?.affectedByGravity = true
                break
            case MoveStates.tower:
                physicsBody?.categoryBitMask = CollisionType.tower.rawValue
                physicsBody?.collisionBitMask = CollisionType.ball.rawValue | CollisionType.flier.rawValue
                physicsBody?.contactTestBitMask = CollisionType.ball.rawValue | CollisionType.flier.rawValue | CollisionType.enemy.rawValue
                physicsBody?.allowsRotation = false
                physicsBody?.isDynamic = false
                for node in children {
                    node.removeFromParent()
                }
                fireLevel = 0
                hits = stats.maxHits
                name = "tower"
                break
            }
        }
    }
    
    init(statistics: BallStats) {
        stats = statistics
        lifetime = 0
        turretAngle = .pi
        targetInRange = false
        hits = statistics.maxHits
        moveState = MoveStates.flier
        fireLevel = 0
        lastFireTick = 0
        let texture = SKTexture(imageNamed: statistics.sprite)
        super.init(texture: texture, color: .white, size: texture.size())
        physicsBody = SKPhysicsBody(circleOfRadius: texture.size().width / 2)
        physicsBody?.usesPreciseCollisionDetection = true
        physicsBody?.density = CGFloat(statistics.density)
        physicsBody?.restitution = 1
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = CollisionType.flier.rawValue
        physicsBody?.collisionBitMask = CollisionType.ball.rawValue | CollisionType.tower.rawValue
        physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
    }
    
    func onDeath() {
        for node in children {
            node.removeFromParent()
        }
        if let deathExplosion = SKEmitterNode(fileNamed: "Death") {
            deathExplosion.position = position
            parent?.addChild(deathExplosion)
            let sequence = SKAction.sequence([SKAction.wait(forDuration: 2), .removeFromParent()])
            deathExplosion.run(sequence)
        }
        self.removeFromParent()
    }
    
    func onTimeout() {
        switch stats.deathType {
        case 1: //Bumper
            let newTex = SKTexture(imageNamed: "square")
            let texChange = SKAction.setTexture(newTex, resize: false)
            run(texChange)
            physicsBody = SKPhysicsBody(rectangleOf: size)
            moveState = MoveStates.tower
            physicsBody?.restitution = 2
            break
        case 2: //Brazier
            let newTex = SKTexture(imageNamed: "square")
            let texChange = SKAction.setTexture(newTex, resize: false)
            run(texChange)
            physicsBody = SKPhysicsBody(rectangleOf: size)
            moveState = MoveStates.tower
            physicsBody?.restitution = 1
            
            if let aoe = SKEmitterNode(fileNamed: "FireAoe") {
                aoe.name = "fire"
                aoe.physicsBody = SKPhysicsBody(circleOfRadius: 50)
                aoe.physicsBody?.isDynamic = false
                aoe.physicsBody?.categoryBitMask = CollisionType.fire.rawValue
                aoe.physicsBody?.collisionBitMask = 0
                aoe.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.ball.rawValue
                addChild(aoe)
            }
            break
        case 3: //Turret
            let newTex = SKTexture(imageNamed: "square")
            let texChange = SKAction.setTexture(newTex, resize: false)
            run(texChange)
            physicsBody = SKPhysicsBody(rectangleOf: size)
            moveState = MoveStates.tower
            physicsBody?.restitution = 1
            zPosition = 1
            
            let targettingArea = SKShapeNode(circleOfRadius: 200)
            targettingArea.alpha = 0.25
            targettingArea.zPosition = 0
            addChild(targettingArea)
            
            let turretHead = SKSpriteNode(imageNamed: "playerWeapon")
            turretHead.zRotation = turretAngle
            turretHead.zPosition = 2
            addChild(turretHead)
            
            break
        default:
            onDeath()
        }
    }
    
    func shoot() {
        let texture = SKTexture(imageNamed: "playerWeapon")
        let projectile = SKSpriteNode(texture: texture)
        projectile.name = "arrow"
        projectile.zRotation = turretAngle
        projectile.position = position
        projectile.physicsBody = SKPhysicsBody(rectangleOf: texture.size())
        projectile.physicsBody?.categoryBitMask = CollisionType.towerProjectile.rawValue
        projectile.physicsBody?.collisionBitMask = 0
        projectile.physicsBody?.contactTestBitMask = CollisionType.end.rawValue | CollisionType.wall.rawValue | CollisionType.enemy.rawValue
        projectile.physicsBody?.affectedByGravity = false
        parent?.addChild(projectile)
        projectile.physicsBody?.applyImpulse(CGVector(dx: 10 * cos(turretAngle), dy: 10 * sin(turretAngle)))
        let sequence = SKAction.sequence([SKAction.wait(forDuration: 10), .removeFromParent()])
        projectile.run(sequence)
    }
    
    func update(time: Double) {
        if lifetime == 0 {
            lifetime = time
        }
        
        //Keep speed below ludicrous levels
        let dxSq = (physicsBody?.velocity.dx ?? 0) * (physicsBody?.velocity.dx ?? 0)
        let dySq = (physicsBody?.velocity.dy ?? 0) * (physicsBody?.velocity.dy ?? 0)
        let magSq = dxSq + dySq
        if magSq > 10000000 {
            physicsBody?.velocity.dx = (physicsBody?.velocity.dx ?? 0) / 2
            physicsBody?.velocity.dy = (physicsBody?.velocity.dy ?? 0) / 2
        }
        
        switch moveState {
        case MoveStates.flier:
            guard position.x < 305 else { break }
            guard time < lifetime + 8 else {
                self.removeFromParent()
                return
            }
            moveState = MoveStates.ball
            break
        case MoveStates.ball:
            guard time > lifetime + 8 else { break }
            onTimeout()
            break
        case MoveStates.tower:
            guard stats.deathType == 3 else { break } //Turret type
            guard targetInRange else { break }
            guard time > lifetime + 3 else { break }
            lifetime = time
            shoot()
            break
        }
        
        //Fire behaviour
        guard stats.flammable else { return }
        guard fireLevel > 0 else { return }
        guard lastFireTick + 2 < time else { return }
        
        lastFireTick = time
        fireLevel -= 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Nope")
    }
}
