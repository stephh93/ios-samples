//
//  SKOverlay.swift
//  ArKit Tutorial
//
//  Created by Stephan on 06.10.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import UIKit
import SpriteKit

class SKOverlay: SKScene {
    var scoreNode: SKLabelNode!
    
    var score = 0 {
        didSet {
            self.scoreNode.text = "Score: \(self.score)"
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor.clear
    
        self.scoreNode = SKLabelNode(text: "Score: 0")
        self.scoreNode.fontName = "DINAlternate-Bold"
        self.scoreNode.fontColor = UIColor.black
        self.scoreNode.fontSize = 32
        self.scoreNode.position = CGPoint(x: size.width/2, y: 40)
        
        self.addChild(self.scoreNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
