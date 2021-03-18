//
//  MenuScene.swift
//  FireTD
//
//  Created by LANCASTER, TRISTAN on 09/12/2019.
//  Copyright © 2019 LANCASTER, TRISTAN. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    let highscores = UserDefaults.standard
    let levelOne = SKShapeNode(rectOf: CGSize(width: 250, height: 100), cornerRadius: 10)
    let levelTwo = SKShapeNode(rectOf: CGSize(width: 250, height: 100), cornerRadius: 10)
    let levelOneName = "level1"
    let levelTwoName = "level2"
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "checkerboard.png")
        background.alpha = 0.5
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        addChild(background)
        
        let title = SKLabelNode(fontNamed:  "HelveticaNeue-Bold")
        title.position = CGPoint(x: 512, y: 600)
        title.fontSize = 72
        title.text = "Fire Tower Defence"
        title.zPosition = 100
        title.horizontalAlignmentMode = .center
        title.fontColor = .red
        addChild(title)
        
        //Level 1
        let levelOneLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Thin")
        levelOneLabel.position = CGPoint(x: 200, y: 360)
        levelOneLabel.fontSize = 24
        levelOneLabel.text = "Level 1"
        levelOneLabel.zPosition = 100
        levelOneLabel.horizontalAlignmentMode = .center
        levelOneLabel.fontColor = .black
        addChild(levelOneLabel)
        
        if let highScoreOne = highscores.object(forKey: levelOneName) as? Int {
            let scoreLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Thin")
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: highScoreOne as NSNumber) ?? "0"
            scoreLabel.text = "Highscore: \(formattedScore)"
            
            scoreLabel.position = CGPoint(x: 200, y: 325)
            scoreLabel.fontSize = 24
            scoreLabel.zPosition = 100
            scoreLabel.horizontalAlignmentMode = .center
            scoreLabel.fontColor = .black
            addChild(scoreLabel)
        }
        
        levelOne.position = CGPoint(x: 200, y: 350)
        levelOne.fillColor = .white
        addChild(levelOne)
        
        //Level 2
        let levelTwoLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Thin")
        levelTwoLabel.position = CGPoint(x: 512, y: 360)
        levelTwoLabel.fontSize = 24
        levelTwoLabel.text = "Level 2"
        levelTwoLabel.zPosition = 100
        levelTwoLabel.horizontalAlignmentMode = .center
        levelTwoLabel.fontColor = .black
        addChild(levelTwoLabel)
        
        if let highScoreTwo = highscores.object(forKey: levelTwoName) as? Int {
            let scoreLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Thin")
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: highScoreTwo as NSNumber) ?? "0"
            scoreLabel.text = "Highscore: \(formattedScore)"
            
            scoreLabel.position = CGPoint(x: 512, y: 325)
            scoreLabel.fontSize = 24
            scoreLabel.zPosition = 100
            scoreLabel.horizontalAlignmentMode = .center
            scoreLabel.fontColor = .black
            addChild(scoreLabel)
        }
        
        levelTwo.position = CGPoint(x: 512, y: 350)
        levelTwo.fillColor = .white
        addChild(levelTwo)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if levelOne.contains(touch.location(in: self)) {
                let newScene = GameScene(fileNamed: "GameScene")
                newScene?.scaleMode = .aspectFill
                newScene?.levelName = levelOneName
                self.view!.presentScene(newScene!, transition: SKTransition.fade(withDuration: 0.5))
                return
            } else if levelTwo.contains(touch.location(in: self)) {
                let newScene = GameScene(fileNamed: "GameScene")
                newScene?.scaleMode = .aspectFill
                newScene?.levelName = levelTwoName
                self.view!.presentScene(newScene!, transition: SKTransition.fade(withDuration: 0.5))
                return
            }
        }
    }
}

