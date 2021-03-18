//
//  VictoryScene.swift
//  FireTD
//
//  Created by LANCASTER, TRISTAN on 09/12/2019.
//  Copyright © 2019 LANCASTER, TRISTAN. All rights reserved.
//

import SpriteKit

class VictoryScene: SKScene {
    var victory = true
    var score = 0
    var remainingGold = 0
    var levelName = "level1"
    let highscores = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        let title = SKLabelNode(fontNamed:  "HelveticaNeue-Bold")
        title.position = CGPoint(x: 512, y: 600)
        title.fontSize = 64
        if victory {
            title.text = "Victory"
            title.fontColor = .orange
        } else {
            title.text = "Defeat"
            title.fontColor = .blue
        }
        title.zPosition = 100
        title.horizontalAlignmentMode = .center
        addChild(title)
        
        let finalScore = score + remainingGold
        let scoreLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Bold")
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formScore = formatter.string(from: score as NSNumber) ?? "0"
        let formGold = formatter.string(from: remainingGold as NSNumber) ?? "0"
        let formFinal = formatter.string(from: finalScore as NSNumber) ?? "0"
        scoreLabel.text = "Score: \(formScore) + \(formGold) = \(formFinal)"
        scoreLabel.position = CGPoint(x: 512, y: 200)
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .cyan
        scoreLabel.zPosition = 100
        scoreLabel.horizontalAlignmentMode = .center
        addChild(scoreLabel)
        
        guard victory else { return }
        if let oldScore = highscores.object(forKey: levelName) as? Int {
            if finalScore > oldScore {
                let highLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Bold")
                highLabel.position = CGPoint(x: 512, y: 400)
                highLabel.fontSize = 36
                highLabel.text = "New High Score!"
                highLabel.fontColor = .orange
                highLabel.zPosition = 100
                highLabel.horizontalAlignmentMode = .center
                addChild(highLabel)
                highscores.set(finalScore, forKey: levelName)
            }
        } else {
            let highLabel = SKLabelNode(fontNamed:  "HelveticaNeue-Bold")
            highLabel.position = CGPoint(x: 512, y: 400)
            highLabel.fontSize = 36
            highLabel.text = "New High Score!"
            highLabel.fontColor = .orange
            highLabel.zPosition = 100
            highLabel.horizontalAlignmentMode = .center
            addChild(highLabel)
            highscores.set(finalScore, forKey: levelName)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newScene = MenuScene(size: self.size)
        newScene.scaleMode = .aspectFill
        self.view!.presentScene(newScene, transition: SKTransition.reveal(with: .down, duration: 0.5))
    }
}
