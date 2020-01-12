//
//  ViewController.swift
//  SimpleBox
//
//  Created by Turker Koc on 1.07.2019.
//  Copyright © 2019 Turker Koc. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")! //this is showing ship given default
        let scene = SCNScene() //creating empty scene
        
        // Set the scene to the view
        sceneView.scene = scene
        
        //everything in ARKit is in meters
        let box = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0) //creating 3D box with specified geometry
        //chamferRadius = benting corner
        
        let material = SCNMaterial() //material is like dress of our object
        material.diffuse.contents = UIColor.red //color of object also you can assing an image too
        
        box.materials = [material] //Assigning material to cube
        
        let boxNode = SCNNode(geometry: box) //box node can be added into real world by using specified geomtery
        boxNode.position = SCNVector3(0, 0, -0.5) //x,y,z -> z = how far the object will be from me
        
        self.sceneView.scene.rootNode.addChildNode(boxNode) // adding node into real world
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

}
