//
//  ARFitnessViewController.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 7/2/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import ARKit
import RealityKit
import UIKit

class ARViewController: UIViewController {
    @IBOutlet weak var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.session.delegate = self
        
        setupARView()
        setupGestureRecognizers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupARView() {
        arView.automaticallyConfigureSession = false
//        arView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Create new configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical, .horizontal]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)
    }
    
    private func setupGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedHorizontalPlane(recognizer:)))
        arView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func tappedHorizontalPlane(recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: arView)
        
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            // Found a horizontal surface
            // Create and place anchor
            let anchor = ARAnchor(name: "toy_drummer", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            // Notify user
            print("Object placement failed - Couldn't find surface")
        }
    }
    
    private func placeObject(named entityName: String, for anchor: ARAnchor) {
        do {
            let entity = try ModelEntity.loadModel(named: entityName)
            
            entity.generateCollisionShapes(recursive: true)
            arView.installGestures(.all, for: entity)
            
            let anchorEntity = AnchorEntity(anchor: anchor)
            anchorEntity.addChild(entity)
            arView.scene.addAnchor(anchorEntity)
        } catch let error {
            print("Error loading the model for entity named: \(entityName).\nError: \(error)")
        }
    }
}

extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "" {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}
