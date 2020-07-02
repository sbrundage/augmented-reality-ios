//
//  PracticePlaneDetection.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 4/12/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import ARKit

class PracticePlaneDetection: UIViewController {
    
    var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set frame for sceneView
        sceneView = ARSCNView(frame: view.frame)
        
        configureSceneSettings()
        
        // Create scene
        let scene = SCNScene()
        
        sceneView.scene = scene
    }
    
    private func configureSceneSettings() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        sceneView.session.run(configuration)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        sceneView.session.pause()
    }
}

extension PracticePlaneDetection: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Check to see if we found a AR Plane Anchor
        if let planeAnchor = anchor as? ARPlaneAnchor {
            
            // Check alignment of the plane
            // if alignment is horizontal, then plane will be red, else blue
            let planeColor: UIColor = planeAnchor.alignment == .horizontal ? .red : .blue
            
            let plane = ARPlane(anchor: anchor, color: planeColor)
            
            // TAKE THIS FUNCTIONALITY OUT OF THIS VIEW CONTROLLER
            // Create plane geomgetry
            let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                         height: CGFloat(planeAnchor.extent.z))
            
            // Create material
            let material = SCNMaterial()
            material.diffuse.contents = planeColor.withAlphaComponent(0.8)
            
            planeGeometry.firstMaterial = material
            
            // Create plane node
            let planeNode = SCNNode(geometry: planeGeometry)
            
            node.addChildNode(planeNode)
        }
    }
}
