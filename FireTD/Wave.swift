//
//  Wave.swift
//  FireTD
//
//  Created by LANCASTER, TRISTAN on 24/11/2019.
//  Copyright © 2019 LANCASTER, TRISTAN. All rights reserved.
//

import SpriteKit

struct PathPoint: Codable {
    let x: CGFloat
    let y: CGFloat
}

struct EnemyStats: Codable {
    let sprite: String
    let moveSpeed: CGFloat
    let maxHealth: Int
    let flammable: Bool
    let delay: Double
    let number: Int
}

struct Wave: Codable {
    let path: [PathPoint]
    let enemies: [EnemyStats]
}

struct Level: Codable {
    let background: String
    let startingGold: Int
    let startingHealth: Int
    let waves: [Wave]
}
