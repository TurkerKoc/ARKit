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
    var spheres = [SCNNode]() //array for points added to fing distance between them
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")! //this is showing ship given default
        let scene = SCNScene() //creating empty scene
        
        addCrossSign()
        registerGestureRecognizers()
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    //when i tap it will call tapped function
    private func registerGestureRecognizers()
    {
        //when you tap anywhere it will call tapped function
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGestureRecognizer.numberOfTapsRequired = 1

        self.sceneView.addGestureRecognizer(tapGestureRecognizer) //adding tap Gesture to our sceneView
    }
    
    @objc func tapped(recognizer :UIGestureRecognizer)
    {
        let sceneView = recognizer.view as! ARSCNView
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        let touchLocation  = CGPoint(x: w / 2, y: h / 2) //setting touch location to mid of screen
        
        let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint) //it is going to find out a point in the real world where the iphone camera is hitting
        //feature point is automaticly found by ARKit
        
        if !hitTestResults.isEmpty //if it found a feature point
        {
            guard let hitTestResult = hitTestResults.first else {
                return
            }
            let sphere = SCNSphere(radius: 0.005) //0.005 meters sphere will be added into the middle
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            sphere.firstMaterial = material
            
            let sphereNode = SCNNode(geometry: sphere) //creating node
            sphereNode.position = SCNVector3(hitTestResult.worldTransform.columns.3.x,hitTestResult.worldTransform.columns.3.y,hitTestResult.worldTransform.columns.3.z) //placing the location
            self.sceneView.scene.rootNode.addChildNode(sphereNode) //adding it into the world
            self.spheres.append(sphereNode)
            
            if self.spheres.count == 2 //if you added 2 point then you should find distance
            {
                let firstPoint = self.spheres.first!
                let secondPoint = self.spheres.last! //taking points into a var
                
                let position = SCNVector3Make(secondPoint.position.x - firstPoint.position.x, secondPoint.position.y - firstPoint.position.y,secondPoint.position.z - firstPoint.position.z)
                let result = sqrt(position.x*position.x + position.y*position.y + position.z*position.z)
                self.spheres.removeAll() //removing last points to add new ones
                
                let displayPoint = SCNVector3((firstPoint.position.x+secondPoint.position.x)/2, (firstPoint.position.y+secondPoint.position.y)/2,(firstPoint.position.z+secondPoint.position.z))
                display(distance: result, position: displayPoint)
            }
        }
    }
    
    //to display result of distance
    private func display(distance: Float,position :SCNVector3)
    {
        let textGeo = SCNText(string: "\(distance)m", extrusionDepth: 1.0) //extrusion -> depth of text in 3D view
        textGeo.firstMaterial?.diffuse.contents = UIColor.black
        
        let textNode = SCNNode(geometry: textGeo)
        textNode.position = position
        textNode.scale = SCNVector3(0.002,0.002,0.002)
        
        self.sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
    private func addCrossSign()
    {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 33))
        label.text = "+"
        label.textAlignment = .center
        
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        label.center = CGPoint(x: w / 2, y: h / 2) //adding it into the middle of the screen

        self.sceneView.addSubview(label) //add the label into sceneView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal //enabling plane detection for measuring
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}
