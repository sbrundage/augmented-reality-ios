//
//  ViewController.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 2/16/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import UIKit
import ARKit

enum BodyType: Int {
    case bullet = 1
    case target = 2
    case car = 3
    case plane = 4
}

class TargetAppViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let scene = SCNScene()
        
        // Add stuff to the scene
        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        boxGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        let box1Node = SCNNode(geometry: boxGeometry)
        box1Node.name = "Target1"
        box1Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box1Node.categoryBitMask = BodyType.target.rawValue
        box1Node.position = SCNVector3(0,0,-0.6)
        
        let box2Node = SCNNode(geometry: boxGeometry)
        box2Node.name = "Target2"
        box2Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box2Node.categoryBitMask = BodyType.target.rawValue
        box2Node.position = SCNVector3(0.2,0.5,-0.8)
        
        let box3Node = SCNNode(geometry: boxGeometry)
        box3Node.name = "Target3"
        box3Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box3Node.categoryBitMask = BodyType.target.rawValue
        box3Node.position = SCNVector3(-0.2,0.5,-0.8)
        
        scene.rootNode.addChildNode(box1Node)
        scene.rootNode.addChildNode(box2Node)
        scene.rootNode.addChildNode(box3Node)
        
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self
        
        registerGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        sceneView.session.run(configuration)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        sceneView.session.pause()
    }
    
    private func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shoot))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func shoot(recognizer: UITapGestureRecognizer) {
        guard let currentFrame = self.sceneView.session.currentFrame else { return }
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.3
        
        let sphere = SCNSphere(radius: 0.05)
        sphere.firstMaterial?.diffuse.contents = UIColor.blue
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.name = "Bullet"
        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        sphereNode.physicsBody?.isAffectedByGravity = false
        sphereNode.physicsBody?.contactTestBitMask = BodyType.target.rawValue
        sphereNode.categoryBitMask = BodyType.bullet.rawValue
        sphereNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        let forceVector = SCNVector3(sphereNode.worldFront.x * 2, sphereNode.worldFront.y * 2, sphereNode.worldFront.z * 2)
        sphereNode.physicsBody?.applyForce(forceVector, asImpulse: true)
        
        self.sceneView.scene.rootNode.addChildNode(sphereNode)
    }
}

// MARK: - SCNPhysicsContactDelegate Methods
extension TargetAppViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        var contactNode: SCNNode!
        
        if contact.nodeA.name == "Bullet" {
            contactNode = contact.nodeB
            let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
            boxGeometry.firstMaterial?.diffuse.contents = UIColor.green
            
            contactNode.geometry = boxGeometry
        } else {
            contactNode = contact.nodeA
            let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
            boxGeometry.firstMaterial?.diffuse.contents = UIColor.green
            
            contactNode.geometry = boxGeometry
        }
    }
}
