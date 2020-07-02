//
//  ARPlane.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 4/12/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import ARKit

class ARPlane: SCNNode {
    var anchor: ARAnchor
    var planeGeometry: ARPlaneAnchor!
    var planeColor: UIColor
    
    init(anchor: ARAnchor, color: UIColor) {
        self.anchor = anchor
        self.planeColor = color
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
