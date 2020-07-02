//
//  OverlayPlane.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 2/15/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import Foundation
import ARKit

class OverlayPlane: SCNNode {
    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane!
    var planeColor: UIColor
    
    init(anchor: ARPlaneAnchor, color: UIColor) {
        self.anchor = anchor
        self.planeColor = color
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor: ARPlaneAnchor) {
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        let planeNode = self.childNodes.first!
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry))
    }
    
    private func setup() {
        self.planeGeometry = SCNPlane(width: CGFloat(self.anchor.extent.x), height: CGFloat(self.anchor.extent.z))
        
        let material = SCNMaterial()
        material.diffuse.contents = planeColor.withAlphaComponent(0.8)
        
        self.planeGeometry.materials = [material]
        
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry))
        planeNode.physicsBody?.categoryBitMask = BodyType.plane.rawValue
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0, 0)
        
        self.addChildNode(planeNode)
    }
}
