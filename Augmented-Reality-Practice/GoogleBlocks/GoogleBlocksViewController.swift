//
//  GoogleBlocksViewController.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 2/26/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//
// The haunter.dae file is credited to Tipatat Chennavasin from Google Blocks

import UIKit
import ARKit

class GoogleBlocksViewController: UIViewController, ARSCNViewDelegate {
    
    var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)
        
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        
        let haunterScene = SCNScene(named: "haunter.dae")
        let haunterNode = haunterScene?.rootNode.childNode(withName: "haunter", recursively: true)
        haunterNode?.position = SCNVector3(0, 0, -1.5)
        
        let scene = SCNScene()
        
        scene.rootNode.addChildNode(haunterNode!)
        
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        sceneView.session.run(configuration)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        sceneView.session.pause()
    }

}
