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
        
        //FORCE BY DOUBLE TAP
        let doubleTappedGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTappedGestureRecognizer.numberOfTapsRequired = 2
        
        tapGestureRecognizer.require(toFail: doubleTappedGestureRecognizer) //if double tap is present one tap will be failed
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer) //adding tap Gesture to our sceneView
        self.sceneView.addGestureRecognizer(doubleTappedGestureRecognizer) //adding double tap Gesture to our sceneView
    }
    
    //applying force when user double tapped to object
    @objc func doubleTapped(recognizer :UIGestureRecognizer)
    {
        let sceneView = recognizer.view as! ARSCNView //when you double tap it will return UIView we are casting UIView to ARSCNView
        let touch = recognizer.location(in: sceneView) //where did you touched
        
        let hitResults = sceneView.hitTest(touch, options: [:]) //to determine wheter your tap intersects with any SCN object
        
        if !hitResults.isEmpty //if you touch an object
        {
            guard let hitResult = hitResults.first else{ //assing it to the hitResult
                return
            }
            
            let node = hitResult.node //get the intersected node
            
            //getting coordinates of the double tapped place and by saying asImpulse: true -> adding impulse like kicking ball(by false it is used for accelerating car ect.)
            node.physicsBody?.applyForce(SCNVector3(hitResult.worldCoordinates.x * Float(2.0),2.0,hitResult.worldCoordinates.z * Float(2.0)), asImpulse: true)
            
        }
        
    }
    
    //when tapped this func will be called
    @objc func tapped(recognizer :UIGestureRecognizer)
    {
        let sceneView = recognizer.view as! ARSCNView //when you tap it will return UIView we are casting UIView to ARSCNView
        let touchLocation = recognizer.location(in: sceneView) //where did you touched
        
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent) //detecting whether the touched location is on the plane or not
        if !hitTestResult.isEmpty //if you touched a plane
        {
            //then add box else do nothing
            guard let hitResult = hitTestResult.first else {
                return
            }
            
            addBox(hitResult :hitResult) // add box function
        }
    }
    
    //adding box
    private func addBox(hitResult :ARHitTestResult) //the parameter hitResult is the location in the real world
    {
        let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        boxGeometry.materials = [material]
        let boxNode = SCNNode(geometry: boxGeometry)
        
        
        //ADDING PHYSİCS BODY
        //static type-> can not move or collide
        //dynamic type-> can move can collide etc.
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil) //nil -> it will automaticly assign shape to our box
        boxNode.physicsBody?.categoryBitMask = BodyType.box.rawValue //which body type is the box
        
        //with physics body we are putting our ball a little bit above the ground to fall down
        //so the box position will be the position in the hitResult (real location on world)
        boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + Float(0.5),hitResult.worldTransform.columns.3.z)
        
        //add box on the sceneView
        self.sceneView.scene.rootNode.addChildNode(boxNode)
        
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
