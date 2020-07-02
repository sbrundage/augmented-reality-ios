//
//  ViewController.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 2/15/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum BoxType: Int {
    case box = 1
    case plane = 2
}

class PlaceVirtualObjectsViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var planes = [OverlayPlane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Register Tap Recognizer
        registerGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Add plane detection
        configuration.planeDetection = [.horizontal]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Anchor Delegate Functions
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !(anchor is ARPlaneAnchor) { return }
        
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor, color: .red)
        self.planes.append(plane)
        node.addChildNode(plane)
        print("Plane added!")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
        }.first
        
        if plane == nil { return }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    // MARK: - Tap Gesture Recognizer
    private func registerGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    @objc func tapped(recognizer: UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !(hitTestResult.isEmpty) {
            guard let hitResult = hitTestResult.first else { return }
            
            addBulby(at: hitResult)
        }
    }
    
    @objc func doubleTapped(recognizer: UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResults = sceneView.hitTest(touchLocation, options: [:])
        
        if !(hitTestResults.isEmpty) {
            guard let hitResult = hitTestResults.first else { return }
            
            let node = hitResult.node
            node.physicsBody?.applyForce(SCNVector3(hitResult.worldCoordinates.x, 1.0, hitResult.worldCoordinates.z), asImpulse: true)
        }
    }
    
    // Add AR objects
    private func addBox(at hitResult: ARHitTestResult) {
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        
        box.firstMaterial?.diffuse.contents = UIColor.red
        
        let boxNode = SCNNode(geometry: box)
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        boxNode.physicsBody?.categoryBitMask = BoxType.box.rawValue
        boxNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y + 0.5, z: hitResult.worldTransform.columns.3.z)
        
        self.sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    private func addBulby(at hitResult: ARHitTestResult) {
        if let bulbyScene = SCNScene(named: "art.scnassets/pokemon.dae") {
            if let bulbyNode = bulbyScene.rootNode.childNode(withName: "Bulby", recursively: true) {
                bulbyNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y, z: hitResult.worldTransform.columns.3.z)
                self.sceneView.scene.rootNode.addChildNode(bulbyNode)
            } else {
                print("Could not find the child node Bulby")
            }
        } else {
            print("Could not find Pokemon.dae")
        }
    }
}
