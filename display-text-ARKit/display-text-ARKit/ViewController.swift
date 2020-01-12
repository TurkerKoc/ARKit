//
//  ViewController.swift
//  display-text-ARKit
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
        let scene = SCNScene() //empty our scene
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let text = SCNText(string: "Hellor ARKit!",extrusionDepth:  1.0) //extrusion means how much depth you want in your text
        text.firstMaterial?.diffuse.contents = UIColor.blue //in box we used Material but for texts there is only one side so we can use firstMaterial
        
        let textNode = SCNNode(geometry: text) //assigning geomtery
        textNode.position = SCNVector3(0,0,-0.5) //x,y,z
        textNode.scale = SCNVector3(0.02,0.02, 0.02) //scaling it because it really big
        sceneView.scene.rootNode.addChildNode(textNode)
        
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
