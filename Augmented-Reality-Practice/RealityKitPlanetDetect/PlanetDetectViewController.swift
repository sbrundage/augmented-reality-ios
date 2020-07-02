//
//  PlanetDetectViewController.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 4/2/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import UIKit
import RealityKit

class PlanetDetectViewController: UIViewController {
    @IBOutlet var arView: ARView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var sun: Planet.Sun!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoLabel.text = "Tap on a planet for more information"
        
        loadEarth()
        loadSun()
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        sun.notifications.showInfo.post()
    }
    
    private func loadEarth() {
        Planet.loadEarthAsync { [weak self] (result) in
            switch result {
            case .success(let earth):
                self?.arView.scene.anchors.append(earth)
            case .failure(let error):
                print("Error while loading Earth: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadSun() {
        Planet.loadSunAsync { [weak self] (result) in
            switch result {
            case .success(let sun):
                self?.sun = sun
                self?.arView.scene.anchors.append(sun)
                
                let sunInfoAction =
                    sun.actions.allActions.filter({
                        $0.identifier == "SunTapped"
                    }).first
                sunInfoAction?.onAction = { entity in
                    self?.displayInfo()
                }
            case .failure(let error):
                print("Error while loading Sun: \(error.localizedDescription)")
            }
        }
    }
    
    private func displayInfo() {
        DispatchQueue.main.async {
            self.infoLabel.text = """
            The Sun is the star at the center of the Solar System.
            It is a nearly perfect sphere of hot plasma, with internal convective motion that
            generates a magnetic field via a dynamo process.
            """
        }
    }
}
