//
//  Catapult.swift
//  FireTD
//
//  Created by LANCASTER, TRISTAN on 29/11/2019.
//  Copyright © 2019 LANCASTER, TRISTAN. All rights reserved.
//
/*
import SpriteKit

class Catapult: SKSpriteNode {
    var ballType : BallStats
    /*var drawPosition : CGPoint {
        didSet {
            guard firing else { return }
            
            if drawPosition != .zero {
                let mag = sqrt(drawPosition.x * drawPosition.x + drawPosition.y + drawPosition.y)
                let unitVec = CGPoint(x: drawPosition.x / mag, y: drawPosition.y / mag)
                self.zRotation = atan(unitVec.y / unitVec.x)
            }
            
            for node in children {
                node.position = drawPosition
                node.zRotation = self.zRotation
            }
        }
    }*/
    
    init(startingBall: BallStats, sprite: String) {
        ballType = startingBall
        let texture = SKTexture(imageNamed: sprite)
        super.init(texture: texture, color: .white, size: texture.size())
        self.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Oops")
    }
    
    func fire(time: Double, drawPosition: CGPoint) {
        let ball = Ball(statistics: ballType, time: time)
        parent?.addChild(ball)
        let forceVector = CGVector(dx: drawPosition.x * 2, dy: drawPosition.y * 2)
        ball.physicsBody?.applyImpulse(forceVector)
    }
}
*/
