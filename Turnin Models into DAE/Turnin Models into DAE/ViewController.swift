//
//  ViewController.swift
//  PlacingVirtualObjects on Planes
//
//  Created by Turker Koc on 2.07.2019.
//  Copyright © 2019 Turker Koc. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum BodyType : Int {
    case box = 1
    case plane = 2
    case car = 3
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var planes = [OverlayPlane]() //plane array
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView = ARSCNView(frame: self.view.frame)
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        self.view.addSubview(self.sceneView)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGestureRecognizers() //calling tap gesture function
    }
    
    //when i tap it will call tapped function
    private func registerGestureRecognizers()
    {
        //when you tap anywhere it will call tapped function
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer) //adding tap Gesture to our sceneView

    }
    

    
    //when tapped this func will be called
    @objc func tapped(recognizer :UIGestureRecognizer)
    {
        let sceneView = recognizer.view as! ARSCNView
        let touch = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(touch, types: .existingPlaneUsingExtent)
        
        if !hitResults.isEmpty {
            
            guard let hitResult = hitResults.first else {
                return
            }
            
            addTable(hitResult :hitResult)
        }
    }
    
    //adding table (3D model from SketchUp)
    private func addTable(hitResult :ARHitTestResult)
    {
        // Create a new scene
        let scene = SCNScene(named: "bench.dae")!
        
        let benchNode = scene.rootNode.childNode(withName: "SketchUp", recursively: true)
        //  benchNode?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        benchNode?.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y ,hitResult.worldTransform.columns.3.z)
        benchNode?.scale = SCNVector3(0.5,0.5,0.5)
        
        self.sceneView.scene.rootNode.addChildNode(benchNode!)
        
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //if anchor is not a plane anchor then do nothing
        if !(anchor is ARPlaneAnchor) {
            return
        }
        //else
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
    }
    
    //didUpdate is every single time it is trying to detect the plane is trying to find anchors
    //without this it will not create one big plane (it will create small seperate planes(by didAdd renderer)
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        //going thourgh plane array if we find the plane update it
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}
