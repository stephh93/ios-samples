//
//  SCNVector3Extension.swift
//  ArKit Tutorial
//
//  Created by Stephan on 07.08.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector3{

    /**
     * Multiplies the x, y and z fields of a SCNVector3 with the same scalar value and
     * returns the result as a new SCNVector3.
     */
    static func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension SCNNode {
    convenience init(named name: String) {
        self.init()
        
        guard let scene = SCNScene(named: name) else {
            return
        }
        
        for childNode in scene.rootNode.childNodes {
            addChildNode(childNode)
        }
    }
    
}
