//
//  PlaneDetectionViewController.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 3/6/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import UIKit
import ARKit

class PlaneDetectionViewController: UIViewController,  ARSCNViewDelegate {
    
    var sceneView: ARSCNView!
    var planes = [OverlayPlane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup AR scene view
        sceneView = ARSCNView(frame: self.view.frame)
        view.addSubview(sceneView)
        
        // Configure settings for AR scene
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        sceneView.showsStatistics = true
        
        sceneView.delegate = self
        
        // Create and set scene
        let scene = SCNScene()
        
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        sceneView.session.run(configuration)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate Methods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        if let planeAnchor = anchor as? ARPlaneAnchor {
            let alignment = planeAnchor.alignment
            
            let planeColor: UIColor = alignment == .horizontal ? .blue : .red
            let plane = OverlayPlane(anchor: planeAnchor, color: planeColor)
            planes.append(plane)
            node.addChildNode(plane)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane = planes.filter { (plane) -> Bool in
            return plane.anchor.identifier == anchor.identifier
        }.first
        
        if plane == nil { return }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
}
