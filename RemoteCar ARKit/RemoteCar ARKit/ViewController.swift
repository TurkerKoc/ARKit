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
    
    private var car :Car! //object of car class
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView = ARSCNView(frame: self.view.frame)
        
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        self.view.addSubview(self.sceneView)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //  sceneView.showsStatistics = true
        
        let carScene = SCNScene(named: "car.dae")
        guard let node = carScene?.rootNode.childNode(withName: "car", recursively: true) //creating car node
            else{
                return
        }
        self.car = Car(node: node) //initalizing our car object
        let carNode = SCNNode()
        carNode.addChildNode(car!)

        
        // Create a new scene
        let scene = SCNScene()
        
        //self.car?.position = SCNVector3(0,0,-0.5) //50cm away from us
        //scene.rootNode.addChildNode(self.car!) //adding car
        
        setupControlPad()//adding buttons to the screen
        registerGestureRecognizers() //to add car with a tap
        
        // Set the scene to the view
        sceneView.scene = scene
        
    }
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
        let touchLocation = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent) //is user touching on plane
        
        if !hitTestResult.isEmpty //if you touched a plane
        {
            guard let hitResult = hitTestResult.first else{
                return
            }
            self.car?.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + 0.1,hitResult.worldTransform.columns.3.z) //50cm away from us
            self.sceneView.scene.rootNode.addChildNode(self.car!) //adding car
        }
    }
    
    
    //Creating buttons
    private func setupControlPad()
    {
        //adding LEFT BUTTON
        let leftButton = GameButton(frame: CGRect(x: 0, y: self.sceneView.frame.height - 60, width: 50, height: 50))
        {
            //this area is the callback area in the GameButton class
            self.car.turnLeft()
        }
        leftButton.setTitle("left", for: .normal) //normally displayed button
        
        //adding Right BUTTON
        let rightButton = GameButton(frame: CGRect(x: 60 , y: self.sceneView.frame.height - 60, width: 50, height: 50))
        {
            //this area is the callback area in the GameButton class
            self.car.turnRight()
        }
        rightButton.setTitle("right", for: .normal) //normally displayed button
        
        //Acceleration button
        let acceleratorButton = GameButton(frame: CGRect(x: self.sceneView.frame.width - 70, y: self.sceneView.frame.height - 40, width: 60, height: 20))
        {
            //this area is the callback area in the GameButton class
            self.car.accelerate()
        }
        
        
        acceleratorButton.backgroundColor = UIColor.red
        acceleratorButton.layer.cornerRadius = 10.0
        acceleratorButton.layer.masksToBounds = true
        
        self.sceneView.addSubview(leftButton)
        self.sceneView.addSubview(rightButton)
        self.sceneView.addSubview(acceleratorButton)
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

