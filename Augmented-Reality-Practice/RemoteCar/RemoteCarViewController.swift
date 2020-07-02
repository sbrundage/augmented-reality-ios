//
//  RemoteCarViewController.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 3/3/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import UIKit
import ARKit

class RemoteCarViewController: UIViewController, ARSCNViewDelegate {
    
    var sceneView: ARSCNView!
    var planes = [OverlayPlane]()
    
    private var carNode: SCNNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create sceneView & give frame
        sceneView = ARSCNView(frame: self.view.frame)
        
        // Add to view
        self.view.addSubview(sceneView)
        
        // Configure SceneView Options
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        
        // Set ARSCNViewDelegate
        sceneView.delegate = self
        
        // Create car car
        let carScene = SCNScene(named: "car.dae")
        
        // Get car root node
        carNode = carScene?.rootNode.childNode(withName: "car", recursively: true)
        
        // Add physics to the car node
        carNode?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        carNode?.physicsBody?.categoryBitMask = BodyType.car.rawValue
        
        // Add Car Node to scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        registerGestureRecognizers()
        setupControlPad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.horizontal, .horizontal]
        sceneView.session.run(configuration)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - Anchor Delegate Functions
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !(anchor is ARPlaneAnchor) { return }
        
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor, color: .red)
        planes.append(plane)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane = planes.filter { (plane) -> Bool in
            return plane.anchor.identifier == anchor.identifier
        }.first
        
        if plane == nil { return }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    private func setupControlPad() {
        let leftButton = GameButton(frame: CGRect(x: 20, y: self.sceneView.frame.height - 70, width: 60, height: 50)) {
            self.turnLeft()
        }
        leftButton.setTitle("Left", for: .normal)
        self.sceneView.addSubview(leftButton)
        
        let rightButton = GameButton(frame: CGRect(x: 100, y: self.sceneView.frame.height - 70, width: 60, height: 50)) {
            self.turnRight()
        }
        rightButton.setTitle("Right", for: .normal)
        self.sceneView.addSubview(rightButton)
        
        let goButton = GameButton(frame: CGRect(x: self.sceneView.frame.width - 80, y: self.sceneView.frame.height - 70, width: 60, height: 50)) {
            self.accelerate()
        }
        goButton.layer.cornerRadius = 10
        goButton.backgroundColor = .red
        goButton.layer.masksToBounds = true
        goButton.setTitle("Go", for: .normal)
        self.sceneView.addSubview(goButton)
    }
    
    private func turnLeft() {
        self.carNode.physicsBody?.applyTorque(SCNVector4(0, 1, 0, 1.0), asImpulse: false)
    }
    
    private func turnRight() {
        self.carNode.physicsBody?.applyTorque(SCNVector4(0, 1, 0, -1.0), asImpulse: false)
    }
    
    private func accelerate() {
        let force = simd_make_float4(0,0,-10,0)
        let rotateForce = simd_mul(self.carNode.presentation.simdTransform, force)
        let vectorForce = SCNVector3(rotateForce.x, rotateForce.y, rotateForce.z)
        
        self.carNode.physicsBody?.applyForce(vectorForce, asImpulse: false)
    }
    
    private func registerGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        tapRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func singleTap(recognizer: UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            guard let hitResult = hitTestResult.first else { return }
            carNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + 0.1, hitResult.worldTransform.columns.3.z)
            sceneView.scene.rootNode.addChildNode(carNode)
        }
        
    }

}
