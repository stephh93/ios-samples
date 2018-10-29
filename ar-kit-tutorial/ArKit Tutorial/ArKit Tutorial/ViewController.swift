//
//  ViewController.swift
//  ArKit Tutorial
//
//  Created by Stephan on 07.08.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate{
    
    struct CollisionOptions {
        let rawValue: Int
        static let categoryBall = CollisionOptions(rawValue: 1 << 0)
        static let categoryTarget = CollisionOptions(rawValue: 1 << 1)
        static let categoryFloor = CollisionOptions(rawValue: 1 << 2)
        static let categoryCan = CollisionOptions(rawValue: 1 << 4)
    }

    @IBOutlet var sceneView: ARSCNView!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    var planeAnchors: [ARPlaneAnchor] = []
    var skOverlayScene : SKOverlay!
    var startTouchTime: TimeInterval?
    var endTouchTime: TimeInterval?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.gravity = SCNVector3Make(0, -2, 0)
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,  ARSCNDebugOptions.showPhysicsShapes]//, ARSCNDebugOptions.showBoundingBoxes]

        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        self.addTapGestureToSceneView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    

    
    func addTapGestureToSceneView() {
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addTrashCanToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    

    @objc func addTrashCanToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        addFloor(translation)
        
        let scene = SCNScene(named: "art.scnassets/can.scn")
        let node = SCNNode()
        for childNode in (scene?.rootNode.childNodes)! {
            
            // add physics:
            let physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
            physicsBody.collisionBitMask = CollisionOptions.categoryBall.rawValue
            if childNode.name == "Rubbish_Bin_Mat_1"{
                //Important: For collision detection ball's and trashCan's physicsbody contactTestBitMask must be equal!
                physicsBody.contactTestBitMask = CollisionOptions.categoryBall.rawValue | CollisionOptions.categoryCan.rawValue
                physicsBody.categoryBitMask = CollisionOptions.categoryCan.rawValue
            }else if childNode.name == "Vent"{
            //Important: For collision detection ball's and trashCan's physicsbody contactTestBitMask must be equal!
            physicsBody.contactTestBitMask = CollisionOptions.categoryBall.rawValue | CollisionOptions.categoryTarget.rawValue
            physicsBody.categoryBitMask = CollisionOptions.categoryTarget.rawValue
                
            }
            childNode.physicsBody = physicsBody
            node.addChildNode(childNode)
            
    
        }
         node.position = SCNVector3(x,y,z)
    
        removePlane()
      
        addScoreOverlay()
        sceneView.removeGestureRecognizer(self.tapGestureRecognizer)
        addSwipeGestureRecognizer()
        sceneView.scene.rootNode.addChildNode(node)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        
        // Run the view's session
        sceneView.session.run(configuration)
        startTouchTime = nil
        endTouchTime = nil
    }
    
    func addSwipeGestureRecognizer(){
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        swipeUp.direction = .up
        self.sceneView.addGestureRecognizer(swipeUp)
    }
    
    fileprivate func addScoreOverlay() {
        self.skOverlayScene = SKOverlay(size: self.view.bounds.size)
        skOverlayScene.isUserInteractionEnabled = false
        self.sceneView.overlaySKScene = self.skOverlayScene
    }
    
    fileprivate func removePlane() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            guard let name = node.name else { return }
            if name.contains("plane") {
                node.removeFromParentNode()
            }
        }
    }
    
    fileprivate func addFloor(_ translation: float3) {
        //add Floor
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIColor.clear
        
        let physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        physicsBody.contactTestBitMask = CollisionOptions.categoryBall.rawValue | CollisionOptions.categoryFloor.rawValue
        physicsBody.collisionBitMask = CollisionOptions.categoryBall.rawValue
        physicsBody.categoryBitMask = CollisionOptions.categoryFloor.rawValue
        physicsBody.friction = 0.999
        let floorNode = SCNNode(geometry: floor)
        floorNode.physicsBody = physicsBody
        floorNode.position = SCNVector3(x: 0, y: translation.y , z: 0)
        sceneView.scene.rootNode.addChildNode(floorNode)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        var node: SCNNode?
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return node }
        planeAnchors.append(planeAnchor)
        
        let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        planeGeometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.eulerAngles.x = -.pi/2
        node = SCNNode()
        node?.name = "plane" + String(planeAnchors.count)
        node?.addChildNode(planeNode)
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, let planeNode = node.childNodes.first, let plane = planeNode.geometry as? SCNPlane else { return }
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        planeNode.position = SCNVector3(CGFloat(planeAnchor.center.x), CGFloat(planeAnchor.center.y), CGFloat(planeAnchor.center.z))
    }
    

    @objc func handleGesture(_ sender: UISwipeGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.ended { return }
        endTouchTime = Date().timeIntervalSince1970
        

        let (direction, position) = self.getUserVector()
        let ball = creatBall(at: position)
        throwBall(ballNode: ball, direction: direction)
        sceneView.scene.rootNode.addChildNode(ball) 
      
        startTouchTime = nil
        endTouchTime = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard touches.first != nil  else { return }
        startTouchTime = Date().timeIntervalSince1970
    }

    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        var ball : SCNNode?
        var can : SCNNode?
        
        if contact.nodeA.physicsBody!.categoryBitMask == CollisionOptions.categoryBall.rawValue {
            ball = contact.nodeA
        } else if contact.nodeB.physicsBody!.categoryBitMask == CollisionOptions.categoryBall.rawValue {
            ball = contact.nodeB
        }
        if contact.nodeA.physicsBody!.categoryBitMask == CollisionOptions.categoryTarget.rawValue {
            can = contact.nodeA
        } else if contact.nodeB.physicsBody!.categoryBitMask == CollisionOptions.categoryTarget.rawValue {
            can = contact.nodeB
        }
        guard (ball != nil), (can != nil) else {return}
        
            self.skOverlayScene.score += 1
            ball!.removeFromParentNode()
        
    }
    
    func throwBall(ballNode: SCNNode, direction: SCNVector3) {
        
        let timeDifference = endTouchTime! - startTouchTime!
        let velocityComponent = Float(min(max(1 - timeDifference, 0.1), 1.0 ))

        
        let impulseVector = direction * ( velocityComponent * 0.005)
        ballNode.physicsBody?.applyForce(impulseVector, asImpulse: true)
        
    }
    
    func creatBall(at position: SCNVector3) -> SCNNode {
        let geometry = SCNSphere(radius: 0.015)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/papertoss.png")
        geometry.firstMaterial = material
        let node = SCNNode(geometry: geometry)
        node.position = position
        //Set physics
        let phsyicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        phsyicsBody.mass = 0.002
        phsyicsBody.friction = 0.9999
        phsyicsBody.damping = 0.9
        
        phsyicsBody.collisionBitMask =  CollisionOptions.categoryTarget.rawValue | CollisionOptions.categoryFloor.rawValue |
            CollisionOptions.categoryBall.rawValue |
            CollisionOptions.categoryCan.rawValue
        //Important: For collision detection ball's and trashCan's physicsbody contactTestBitMask must be equal!
        phsyicsBody.contactTestBitMask = CollisionOptions.categoryBall.rawValue | CollisionOptions.categoryTarget.rawValue | CollisionOptions.categoryFloor.rawValue |
            CollisionOptions.categoryCan.rawValue
        phsyicsBody.categoryBitMask = CollisionOptions.categoryBall.rawValue
        
        phsyicsBody.isAffectedByGravity = true
        node.physicsBody = phsyicsBody
        return node
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
}
    extension ViewController {
        
        func session(_ session: ARSession, didFailWithError error: Error) {
            // Present an error message to the user
            
        }
        
        func sessionWasInterrupted(_ session: ARSession) {
            // Inform the user that the session has been interrupted, for example, by presenting an overlay
            
        }
        
        func sessionInterruptionEnded(_ session: ARSession) {
            // Reset tracking and/or remove existing anchors if consistent tracking is required
            
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        }
    }

