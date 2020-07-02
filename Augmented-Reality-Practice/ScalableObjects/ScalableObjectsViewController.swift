//
//  ScalableObjectsViewController.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 3/17/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import Foundation
import ARKit
import UIKit
import MBProgressHUD

class ScalableObjectsViewController: UIViewController {
    var sceneView: ARSCNView!
    
    private var hud: MBProgressHUD!
    private var newAngleY: Float = 0.0
    private var currentAngleY: Float = 0.0
    private var localTranslatePosition: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)
        
        sceneView.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        
        registerGestureRecognizers()
        setupHUD()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    private func setupHUD() {
        DispatchQueue.main.async {
            self.hud = MBProgressHUD.showAdded(to: self.sceneView, animated: true)
            self.hud.label.text = "Detecting Planes..."
        }
    }
    
    private func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned))
        sceneView.addGestureRecognizer(panGestureRecognizer)
        
//        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
//        sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else { return }
        
        // Screen coordinate system (CGPoint)
        let touch = recognizer.location(in: sceneView)
        
        let hitTestResults = sceneView.hitTest(touch, types: .existingPlane)
        if let hitTest = hitTestResults.first {
            guard let tableScene = SCNScene(named: "table.dae") else { fatalError("Could not find DAE file") }
            
            if let tableNode = tableScene.rootNode.childNode(withName: "table", recursively: true) {
                tableNode.position = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
                sceneView.scene.rootNode.addChildNode(tableNode)
            } else { print("Could not create table node") }
        }
    }
    
    @objc func pinched(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .changed {
            guard let sceneView = recognizer.view as? ARSCNView else { return }
            
            let touch = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(touch, options: nil)
            
            if let hitTest = hitTestResults.first {
                let tableNode = hitTest.node
                let pinchScaleX = Float(recognizer.scale) * tableNode.scale.x
                let pinchScaleY = Float(recognizer.scale) * tableNode.scale.y
                let pinchScaleZ = Float(recognizer.scale) * tableNode.scale.z
                
                tableNode.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
                recognizer.scale = 1
            }
        }
    }
    
    @objc func panned(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .changed {
            guard let sceneView = recognizer.view as? ARSCNView else { return }
            
            let touch = recognizer.location(in: sceneView)
            let translation = recognizer.translation(in: sceneView)
            
            let hitTestResults = sceneView.hitTest(touch, options: nil)
            
            if let hitTest = hitTestResults.first {
                let tableNode = hitTest.node
                
                newAngleY = Float(translation.x) * (Float) (Double.pi)/180
                newAngleY += currentAngleY
                tableNode.eulerAngles.y = newAngleY
            }
        } else if recognizer.state == .ended {
            currentAngleY = newAngleY
        }
    }
    
//    @objc func longPressed(recognizer: UILongPressGestureRecognizer) {
//        guard let sceneView = recognizer.view as? ARSCNView else { return }
//
//        let touch = recognizer.location(in: sceneView)
//        let hitTestResult = sceneView.hitTest(touch, options: nil)
//
//        if let hitTest = hitTestResult.first {
//
//            let tableNode = hitTest.node
//
//            if recognizer.state == .began {
//                localTranslatePosition = touch
//            } else if recognizer.state == .changed {
//                let deltaX = (touch.x - localTranslatePosition.x) / 700
//                let deltaY = (touch.y - localTranslatePosition.y) / 700
//
//                tableNode.localTranslate(by: SCNVector3(deltaX, 0.0, deltaY))
//                localTranslatePosition = touch
//            }
//        }
//    }
}

// MARK: - ARSCNView Delegate Methods
extension ScalableObjectsViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            
            DispatchQueue.main.async {
                self.hud.label.text = "Plane Detected!"
                self.hud.hide(animated: true, afterDelay: 1.0)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Implement
    }
}
