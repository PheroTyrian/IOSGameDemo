//
//  GameScene.swift
//  FireTD
//
//  Created by LANCASTER, TRISTAN on 24/11/2019.
//  Copyright © 2019 LANCASTER, TRISTAN. All rights reserved.
//

import SpriteKit
import CoreMotion

enum CollisionType: UInt32 {
    case wall = 1
    case tower = 2
    case towerProjectile = 4
    case ball = 8
    case flier = 16
    case enemy = 32
    case fire = 64
    case end = 128
    case dieing = 256
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    //Motion tracking
    var motionManager: CMMotionManager?
    //Level tracking variables
    var ballStats = Bundle.main.decode([BallStats].self, from: "ballStats")
    var levelName = ""
    var levelStats: Level? = nil
    var endlessMode = false
    var currentWave = -1
    var currentPath: CGPath = UIBezierPath().cgPath
    //Wave spawning tracking variables
    var spawnIter = 0
    var lastSpawn: Double = 0
    var spawnNum = 0
    //Touch tracking objects
    var isFiring = false
    var selectedBall: Int = 0
    let firingLocation = CGPoint(x: 320, y: 0)
    let catapultNodule = SKShapeNode(circleOfRadius: 30)
    let catapultArea = SKShapeNode(rect: CGRect(x: -150, y: 320, width: 300, height: 190))
    //UI related variables
    let leftArrow = SKShapeNode(circleOfRadius: 20)
    let rightArrow = SKShapeNode(circleOfRadius: 20)
    let ballImage = SKSpriteNode(imageNamed: "ballGrey")
    let waveLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    let healthLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Thin")
    var health = 5 {
        didSet {
            if health <= 0 {
                motionManager?.stopAccelerometerUpdates()
                let newScene = VictoryScene(size: self.size)
                newScene.scaleMode = .aspectFill
                newScene.victory = false
                newScene.score = score
                newScene.remainingGold = gold
                newScene.levelName = levelName
                self.view!.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
            }
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedHealth = formatter.string(from: health as NSNumber) ?? "0"
            healthLabel.text = "Health: \(formattedHealth)"
            let sequence = SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.5), SKAction.scale(to: 1, duration: 0.5)])
            healthLabel.run(sequence)
        }
    }
    let goldLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Thin")
    var gold = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedGold = formatter.string(from: gold as NSNumber) ?? "0"
            goldLabel.text = "Gold: \(formattedGold)"
        }
    }
    let scoreLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Thin")
    var score = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: score as NSNumber) ?? "0"
            scoreLabel.text = "Score: \(formattedScore)"
        }
    }
    let ballDescription = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    let costLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    let hitsLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    let flamLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    
    
    override func didMove(to view: SKView) {
        levelStats = Bundle.main.decode(Level.self, from: levelName)
        
        //Calling functions for when the app enters or leaves focus
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        //World physics
        physicsWorld.contactDelegate = self
        motionManager = CMMotionManager()
        if motionManager?.isAccelerometerAvailable ?? false {
            motionManager?.accelerometerUpdateInterval = 0.1
            motionManager?.startAccelerometerUpdates()
        }
        
        //Create walls
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 200)))
        physicsBody?.restitution = 1
        physicsBody?.categoryBitMask = CollisionType.wall.rawValue
        physicsBody?.collisionBitMask = CollisionType.ball.rawValue | CollisionType.towerProjectile.rawValue
        physicsBody?.contactTestBitMask = CollisionType.towerProjectile.rawValue
        
        let background = SKSpriteNode(imageNamed: levelStats!.background)
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)
        
        //Create buttons
        waveLabel.fontSize = 24
        waveLabel.position = CGPoint(x: 320, y: 355)
        waveLabel.text = "Wave: 0"
        waveLabel.zPosition = 100
        waveLabel.horizontalAlignmentMode = .left
        addChild(waveLabel)
        
        healthLabel.fontSize = 24
        healthLabel.position = CGPoint(x: 320, y: 235)
        healthLabel.text = "Health: 0"
        healthLabel.zPosition = 100
        healthLabel.horizontalAlignmentMode = .left
        addChild(healthLabel)
        health = levelStats!.startingHealth
        
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: 320, y: 315)
        scoreLabel.text = "Score: 0"
        scoreLabel.zPosition = 100
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        goldLabel.fontSize = 24
        goldLabel.position = CGPoint(x: 320, y: 275)
        goldLabel.text = "Gold: 0"
        goldLabel.zPosition = 100
        goldLabel.horizontalAlignmentMode = .left
        addChild(goldLabel)
        gold = levelStats!.startingGold
        
        ballDescription.fontSize = 20
        ballDescription.position = CGPoint(x: 320, y: -250)
        ballDescription.text = ""
        ballDescription.zPosition = 100
        ballDescription.horizontalAlignmentMode = .left
        addChild(ballDescription)
        
        costLabel.fontSize = 20
        costLabel.position = CGPoint(x: 320, y: -274)
        costLabel.text = ""
        costLabel.zPosition = 100
        costLabel.horizontalAlignmentMode = .left
        addChild(costLabel)
        
        hitsLabel.fontSize = 20
        hitsLabel.position = CGPoint(x: 320, y: -298)
        hitsLabel.text = ""
        hitsLabel.zPosition = 100
        hitsLabel.horizontalAlignmentMode = .left
        addChild(hitsLabel)
        
        flamLabel.fontSize = 20
        flamLabel.position = CGPoint(x: 320, y: -322)
        flamLabel.text = ""
        flamLabel.zPosition = 100
        flamLabel.horizontalAlignmentMode = .left
        addChild(flamLabel)
        
        catapultNodule.position = CGPoint(x: 320, y: 0)
        catapultNodule.zPosition = 3
        addChild(catapultNodule)
        catapultArea.zRotation = 0 - (.pi/2)
        catapultArea.zPosition = 2
        addChild(catapultArea)
        
        leftArrow.position = CGPoint(x: 350, y: -200)
        leftArrow.zPosition = 100
        addChild(leftArrow)
        rightArrow.position = CGPoint(x: 480, y: -200)
        rightArrow.zPosition = 100
        addChild(rightArrow)
        ballImage.position = CGPoint(x: 415, y: -200)
        ballImage.zPosition = 100
        addChild(ballImage)
        newBallSelected()
        
        let endTexture = SKTexture(imageNamed: "enemy3")
        let endZone = SKSpriteNode(texture: endTexture)
        endZone.position = CGPoint(x: firingLocation.x - 10, y: firingLocation.y)
        endZone.zRotation = .pi / 2
        endZone.name = "end"
        endZone.physicsBody = SKPhysicsBody(circleOfRadius: endTexture.size().width / 4)
        endZone.physicsBody?.isDynamic = false
        endZone.physicsBody?.categoryBitMask = CollisionType.end.rawValue
        endZone.physicsBody?.collisionBitMask = CollisionType.ball.rawValue | CollisionType.towerProjectile.rawValue
        endZone.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
        addChild(endZone)
        
        score = -100
        nextWave()
    }
    
    @objc func appMovedToBackground() {
        motionManager?.stopAccelerometerUpdates()
        view?.isPaused = true
    }
    
    @objc func appMovedToForeground() {
        motionManager?.startAccelerometerUpdates()
        view?.isPaused = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -10, dy: accelerometerData.acceleration.x * 10)
        }
        
        let activeEnemies = children.compactMap { $0 as? Enemy }
        let activeBalls = children.compactMap { $0 as? Ball }
        
        for enemy in activeEnemies {
            if enemy.burn(time: currentTime) {
                gold += 4
                score += 4
            }
        }
        
        for ball in activeBalls {
            //Kill misbehaving oob balls
            if !frame.intersects(ball.frame) {
                //money += ball.cost
                ball.removeFromParent()
            }
            if ball.moveState == MoveStates.tower && ball.stats.deathType == 3 { //If ball is a turret
                ball.targetInRange = false
                for enemy in activeEnemies {
                    guard frame.intersects(enemy.frame) else { continue }
                    guard enemy.currentHealth > 0 else { continue }
                    let diff = CGPoint(x: enemy.position.x - ball.position.x, y: enemy.position.y - ball.position.y)
                    let mag = diff.x * diff.x + diff.y * diff.y
                    if mag < 40000 {
                        ball.targetInRange = true
                        ball.turretAngle = atan2(diff.y, diff.x)
                        break
                    }
                }
            }
            
            ball.update(time: currentTime)
        }
        
        //Enemy spawning
        guard spawnIter < levelStats!.waves[currentWave].enemies.count else {
            if activeEnemies.count == 0 { nextWave() }
            return
        }
        if lastSpawn + levelStats!.waves[currentWave].enemies[spawnIter].delay < currentTime {
            let startPos = CGPoint(x: levelStats!.waves[currentWave].path[0].x, y: levelStats!.waves[currentWave].path[0].y)
            let enemy = Enemy(statistics: levelStats!.waves[currentWave].enemies[spawnIter])
            
            //Set starting position and name
            enemy.position = CGPoint(x: startPos.x, y: startPos.y)
            enemy.name = "enemy"
            
            //Path movement
            let move = SKAction.follow(currentPath, asOffset: false, orientToPath: true, speed: enemy.stats.moveSpeed)
            let sequence = SKAction.sequence([move, .removeFromParent()])
            enemy.run(sequence, withKey: "alive")
            addChild(enemy)
            
            lastSpawn = currentTime
            spawnNum += 1
            if spawnNum == levelStats!.waves[currentWave].enemies[spawnIter].number {
                spawnNum = 0
                spawnIter += 1
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let contact1 = contact.bodyA.node else { return }
        guard let contact2 = contact.bodyB.node else { return }
        
        //Arrow, Ball, End, Enemy, Fire, Tower
        let nodes = [contact1, contact2].sorted { $0.name ?? "" < $1.name ?? "" }
        let first = nodes[0]
        let second = nodes[1]
        
        //Projectile collision
        if first.name == "arrow" {
            if let enemy = second as? Enemy {
                if enemy.damage(amount: 1) {
                    gold += 4
                    score += 4
                }
                first.removeFromParent()
            }
        } else if let ball = first as? Ball {//Ball collision
            if let enemy = second as? Enemy {//Ball on enemy
                if ball.hits > 0 && enemy.currentHealth > 0 {
                    if ball.fireLevel > enemy.fireLevel {
                        enemy.fireLevel = ball.fireLevel
                    }
                    ball.hits -= 1
                    if enemy.damage(amount: 1) {
                        gold += 4
                        score += 4
                    }
                }
            }
            if let tower = second as? Ball {//Ball on tower
                if tower.name == "tower" {
                    switch tower.stats.deathType {
                    case 1://Bumper
                        ball.lifetime = 0
                        if ball.stats.maxHits > ball.hits {
                        ball.hits += 1
                        }
                        break
                    case 2://Flame
                        ball.fireLevel = 3
                        break
                    default:
                        break
                    }
                }
            }
            if second.name == "fire" {//Ball on fire
                ball.fireLevel = 3
            }
        } else if first.name == "end" { //End collision
            if let enemy = second as? Enemy {
                if enemy.currentHealth > 0 {
                    if enemy.damage(amount: enemy.currentHealth) {
                        gold += 4
                        score += 4
                    }
                    health -= 1
                }
            }
        } else if let enemy = first as? Enemy {//Enemy collisions
            if second.name == "fire" {
                enemy.fireLevel = 3
            }
            if let tower = second as? Ball {
                let towerDamage = enemy.currentHealth
                if towerDamage > 0 {
                    if enemy.damage(amount: tower.hits) {
                        gold += 4
                        score += 4
                    }
                    tower.hits -= towerDamage
                }
            }
        }
    }
    
    func nextWave() {
        for node in children {
            if node.name == "path" {
                node.removeFromParent()
            }
        }
        currentWave += 1
        spawnIter = 0
        score += 100
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedWave = formatter.string(from: currentWave + 1 as NSNumber) ?? "0"
        waveLabel.text = "Wave: \(formattedWave)"
        
        if currentWave == levelStats!.waves.count {
            if endlessMode {
                currentWave = 0
            } else {
                motionManager?.stopAccelerometerUpdates()
                let newScene = VictoryScene(size: self.size)
                newScene.scaleMode = .aspectFill
                newScene.score = score
                newScene.remainingGold = gold
                newScene.levelName = levelName
                self.view!.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
                return
            }
        }
        let path = UIBezierPath()
        let xUnit = CGFloat(frame.maxX / 12)
        let yUnit = CGFloat(frame.maxY / 9)
        let startPos = CGPoint(x: levelStats!.waves[currentWave].path[0].x * xUnit, y: levelStats!.waves[currentWave].path[0].y * yUnit)
        path.move(to: startPos)
        for i in 1...(levelStats!.waves[currentWave].path.count - 1) {
            let position = CGPoint(x: levelStats!.waves[currentWave].path[i].x * xUnit, y: levelStats!.waves[currentWave].path[i].y * yUnit)
            path.addLine(to: position)
        }
        currentPath = path.cgPath
        let outline = SKShapeNode()
        outline.name = "path"
        outline.path = currentPath
        outline.strokeColor = .brown
        outline.lineWidth = 8
        addChild(outline)
    }
    
    func fire() {
        guard gold - ballStats[selectedBall].cost >= 0 else {
            let sequence = SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.5), SKAction.scale(to: 1, duration: 0.5)])
            goldLabel.run(sequence)
            return
        }
        gold -= ballStats[selectedBall].cost
        let newBall = Ball(statistics: ballStats[selectedBall])
        newBall.position = firingLocation
        newBall.name = "ball"
        addChild(newBall)
        var forceVector = CGVector(dx: (firingLocation.x - catapultNodule.position.x) / 2, dy: (firingLocation.y - catapultNodule.position.y) / 2)
        forceVector.dx = min(forceVector.dx, -6)
        newBall.physicsBody?.applyImpulse(forceVector)
    }
    
    func newBallSelected() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedCost = formatter.string(from: ballStats[selectedBall].cost as NSNumber) ?? "0"
        let formattedHits = formatter.string(from: ballStats[selectedBall].maxHits as NSNumber) ?? "0"
        ballDescription.text = ballStats[selectedBall].description
        costLabel.text = "Cost: \(formattedCost)"
        hitsLabel.text = "Hits: \(formattedHits)"
        if ballStats[selectedBall].flammable { flamLabel.text = "Flammable"
        } else { flamLabel.text = "Not Flammable" }
        
        let newTex = SKTexture(imageNamed: ballStats[selectedBall].sprite)
        let texChange = SKAction.setTexture(newTex, resize: false)
        ballImage.run(texChange)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if catapultNodule.contains(touch.location(in: self)) {
                catapultNodule.position = touch.location(in: self)
                isFiring = true
            } else if leftArrow.contains(touch.location(in: self)) {
                selectedBall -= 1
                if selectedBall < 0 { selectedBall = ballStats.count - 1 }
                newBallSelected()
            } else if rightArrow.contains(touch.location(in: self)) {
                selectedBall += 1
                if selectedBall >= ballStats.count { selectedBall = 0 }
                newBallSelected()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var inCatapult = false
        for touch in touches {
            if isFiring && catapultArea.contains(touch.location(in: self)) {
                catapultNodule.position = touch.location(in: self)
                inCatapult = true
            }
        }
        if !inCatapult && isFiring {
            catapultNodule.position = firingLocation
            isFiring = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFiring {
            isFiring = false
            for touch in touches {
                if catapultArea.contains(touch.location(in: self)) { isFiring = true }
            }
            if isFiring {
                fire()
                catapultNodule.position = firingLocation
                isFiring = false
            }
        }
    }
}
