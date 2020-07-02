//
//  PersistenceViewController.swift
//  Augmented-Reality-Practice
//
//  Created by Stephen Brundage on 3/19/20.
//  Copyright © 2020 Stephen Brundage. All rights reserved.
//

import UIKit
import ARKit
import MBProgressHUD

class PersistenceViewController: UIViewController {
    var sceneView: ARSCNView!
    private var hud: MBProgressHUD!
    
    private lazy var worldMapStatusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveWorldMapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Save", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 53/255, green: 73/255, blue: 94/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(saveWorldMap), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up AR View
        sceneView = ARSCNView(frame: view.frame)
        view.addSubview(sceneView)
        
        // Set delegates
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()
        
        sceneView.scene = scene
        
        registerGestureRecognizers()
        setupUI()
        setupHUD()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        restoreWorldMap()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    private func restoreWorldMap() {
        let userDefaults = UserDefaults.standard
        
        if let data = userDefaults.data(forKey: "box") {
            if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [ARWorldMap.classForKeyedUnarchiver()], from: data),
                let worldMap = unarchived as? ARWorldMap {
                
                let configuration = ARWorldTrackingConfiguration()
                configuration.initialWorldMap = worldMap
                configuration.planeDetection = .horizontal
                
                sceneView.session.run(configuration)
            }
        } else {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            sceneView.session.run(configuration)
        }
    }
    
    private func registerGestureRecognizers() {
        let tapGestureRecongizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGestureRecongizer.numberOfTouchesRequired = 1
        sceneView.addGestureRecognizer(tapGestureRecongizer)
    }
    
    // MARK: - Objective C functions
    @objc private func tapped(recognizer: UITapGestureRecognizer) {
        // Get scene that was tapped
        guard let sceneView = recognizer.view as? ARSCNView else { return }
        
        // Get touch location within view from recognizer
        let touch = recognizer.location(in: sceneView)
        
        // Get hit test results from touch location
        let hitTestResults = sceneView.hitTest(touch, types: .existingPlane)
        if let hitTestResult = hitTestResults.first {
            // Create ARAnchor; Required for persistence to work
            let boxAnchor = ARAnchor(name: "box-anchor", transform: hitTestResult.worldTransform)
            
            // Add anchor to AR session
            sceneView.session.add(anchor: boxAnchor)
        }
    }
    
    @objc private func saveWorldMap() {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            // Get World Map from AR session
            if let map = worldMap {
                let data = try! NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                
                
                let userDefaults = UserDefaults.standard
                userDefaults.set(data, forKey: "box")
                userDefaults.synchronize()
                
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud.label.text = "World Map Saved!"
                self.hud.hide(animated: true, afterDelay: 2.0)
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(saveWorldMapButton)
        view.addSubview(worldMapStatusLabel)
        
        saveWorldMapButton.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor).isActive = true
        saveWorldMapButton.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: -30).isActive = true
        saveWorldMapButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        saveWorldMapButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        worldMapStatusLabel.topAnchor.constraint(equalTo: sceneView.topAnchor, constant: 30).isActive = true
        worldMapStatusLabel.rightAnchor.constraint(equalTo: sceneView.rightAnchor, constant: -30).isActive = true
        worldMapStatusLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    private func setupHUD() {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "Detecting Surfaces..."
    }
}

extension PersistenceViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            DispatchQueue.main.async {
                self.hud.label.text = "Surface Detected!"
                self.hud.hide(animated: true, afterDelay: 2.0)
            }
            return
        }
        
        let boxGeo = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        boxGeo.firstMaterial?.diffuse.contents = UIColor.purple
        let boxNode = SCNNode(geometry: boxGeo)
        node.addChildNode(boxNode)
    }
}

extension PersistenceViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable:
            worldMapStatusLabel.text = "NOT AVAILABLE"
        case .limited:
            worldMapStatusLabel.text = "LIMITED"
        case .extending:
            worldMapStatusLabel.text = "EXTENDING"
        case .mapped:
            worldMapStatusLabel.text = "MAPPED"
        }
    }
}
