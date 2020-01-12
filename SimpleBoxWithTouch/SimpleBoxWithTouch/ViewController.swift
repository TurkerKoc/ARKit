//
//  ViewController.swift
//  SimpleBoxWithTouch
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
        let scene = SCNScene()
        
        //3D BOX
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        let material = SCNMaterial()
        material.name = "Color"
        material.diffuse.contents = UIColor.red
        
        let node = SCNNode()
        node.geometry = box
        node.geometry?.materials = [material]
        node.position = SCNVector3(0,0,-0.5)
        
        scene.rootNode.addChildNode(node)
        
        
        //ADDING TAP GESTURE
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped)) //selector -> funciton called when tapped
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    //when tapped this func will be called
    @objc func tapped(recognizer :UIGestureRecognizer)
    {
        let sceneView = recognizer.view as! SCNView //which view can be tapped
        let touchLocation = recognizer.location(in: sceneView) //where exactly person touched
        let hitResults  = sceneView.hitTest(touchLocation, options: [:]) //to determine touch intersected with which type of an object
        if !hitResults.isEmpty // if you touched some AR object
        {//then change color randomly
            let node = hitResults[0].node
            let material = node.geometry?.material(named: "Color")
            
            material?.diffuse.contents = UIColor.random() //random() func is called in extensions.swift
        }
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
