//
//  MeasurementViewController.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 2/16/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import UIKit
import ARKit

class MeasurementViewController: UIViewController, ARSCNViewDelegate {
    
    var sceneView: ARSCNView!
    var spheres = [SCNNode]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)

        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        let scene = SCNScene()
        
        addCrossSign()
        registerGestureRecognizers()
        
        sceneView.scene = scene
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
    
    private func addCrossSign() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 33))
        label.text = "+"
        label.textAlignment = .center
        label.center = self.sceneView.center
        
        self.sceneView.addSubview(label)
    }
    
    private func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(placeNode))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func placeNode(recognizer: UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = self.sceneView.center
        
        let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
        
        if !hitTestResults.isEmpty {
            guard let hitPoint = hitTestResults.first else { return }
            
            let sphereGeo = SCNSphere(radius: 0.005)
            sphereGeo.materials.first?.diffuse.contents = UIColor.blue
            let sphereNode = SCNNode(geometry: sphereGeo)
            sphereNode.position = SCNVector3(x: hitPoint.worldTransform.columns.3.x, y: hitPoint.worldTransform.columns.3.y, z: hitPoint.worldTransform.columns.3.z)
            
            self.sceneView.scene.rootNode.addChildNode(sphereNode)
            spheres.append(sphereNode)
            
            if spheres.count == 2 {
                // calculate distance between two nodes
                let firstPoint = spheres.first!
                let secondPoint = spheres.last!
                
                let pos1 = firstPoint.position
                let pos2 = secondPoint.position
                
                let position = SCNVector3Make(pos2.x - pos1.x, pos2.y - pos1.y, pos2.z - pos1.z)
                let result = sqrt(pow(position.x, 2) + pow(position.y, 2) + pow(position.z, 2))
                let textPosition = SCNVector3((pos1.x + pos2.x) / 2, (pos1.y + pos2.y) / 2, (pos1.z + pos2.z) / 2)
                
                displayDistance(result, textPosition)
                
                // Reset array
                spheres = []
            }
        }
    }
    
    private func displayDistance(_ measurement: Float, _ position: SCNVector3) {
        let textGeo = SCNText(string: "\(measurement) m", extrusionDepth: 1.0)
        textGeo.firstMaterial?.diffuse.contents = UIColor.black
        
        let textNode = SCNNode(geometry: textGeo)
        textNode.position = position
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        
        self.sceneView.scene.rootNode.addChildNode(textNode)
    }
}
