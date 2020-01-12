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

enum BoxBodyType : Int {
    case bullet = 1
    case barrier = 2 //boxes
}

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate //to get notification when collision occurs
{
    
    @IBOutlet var sceneView: ARSCNView!
    var planes = [OverlayPlane]() //plane array
    var lastContatcNode :SCNNode! //Creating this because when collision occurs it will cause nontification a lot so we can take the last one only
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView = ARSCNView(frame: self.view.frame)
        
        //self.sceneView.debug  Options = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        self.view.addSubview(self.sceneView)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        
        
        //CREATING box1
        let box1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        box1.materials = [material]
        
        
        
        
        //CREATING boxes
        let box1Node = SCNNode(geometry: box1)
        let box2Node = SCNNode(geometry: box1) //all will have same geometries
        let box3Node = SCNNode(geometry: box1)
        
        box2Node.position = SCNVector3(-0.2,0,-0.4)
        box3Node.position = SCNVector3(0.2,0.2,-0.5)
        box1Node.position = SCNVector3(0,0,-0.4)

        box1Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil) //if something hit that it is not going to move so static
        box2Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil) //if something hit that it is not going to move so static
        box3Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil) //if something hit that it is not going to move so
        
        box1Node.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue  //assigning type
        box2Node.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue  //assigning type
        box3Node.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue  //assigning type
        
        box1Node.name = "Barrier1"
        box2Node.name = "Barrier2"
        box3Node.name = "Barrier3"
        
        scene.rootNode.addChildNode(box1Node)
        scene.rootNode.addChildNode(box2Node)
        scene.rootNode.addChildNode(box3Node)

        
        
        
        
        
        // Set the scene to the view
        sceneView.scene = scene
       
        self.sceneView.scene.physicsWorld.contactDelegate = self //you are informing that all delegetations will be informing you
        
        registerGestureRecognizers() //calling tap gesture function
    }
    
    
    //this func will be called when a collision occurs
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact)
    {
        var contactNode :SCNNode!
        
        if contact.nodeA.name == "Bullet"
        {
            contactNode = contact.nodeB //node b is box
        }
        else
        {
            contactNode = contact.nodeA //node a is box
        }
        if self.lastContatcNode != nil && self.lastContatcNode == contactNode //this will provide you take take last collision
        {
            return
        }
        self.lastContatcNode = contactNode
        
        let box1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        box1.materials = [material]
        self.lastContatcNode.geometry = box1 //to turn it into green
    }
    
    //when i tap it will call tapped function
    private func registerGestureRecognizers()
    {
        //when you tap anywhere it will call tapped function
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shoot))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        //FORCE BY DOUBLE TAP
        //let doubleTappedGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        //doubleTappedGestureRecognizer.numberOfTapsRequired = 2
        
        //tapGestureRecognizer.require(toFail: doubleTappedGestureRecognizer) //if double tap is present one tap will be failed
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer) //adding tap Gesture to our sceneView
        //self.sceneView.addGestureRecognizer(doubleTappedGestureRecognizer) //adding double tap Gesture to our sceneView
    }
    
    @objc func shoot(recognizer :UIGestureRecognizer)
    {
        //getting current frame to shoot
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        
        //allow you to place the element also make sure that your element is in correct level
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.3
        
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        
        let boxNode = SCNNode(geometry: box)
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil) //creating it ddynamic to shoot
        boxNode.physicsBody?.isAffectedByGravity = false // to go straight
        boxNode.physicsBody?.categoryBitMask = BoxBodyType.bullet.rawValue //assigning type
        boxNode.physicsBody?.contactTestBitMask = BoxBodyType.barrier.rawValue //will be notified when it collide with box (physicsWorld func will be called)
        boxNode.name = "Bullet"
        
        boxNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation) //transforming to matrix
        let forceVector = SCNVector3(boxNode.worldFront.x * 2, boxNode.worldFront.y * 2, boxNode.worldFront.z * 2) //force will be applied is constant
        
        boxNode.physicsBody?.applyForce(forceVector, asImpulse: true) //impulse as we created
        self.sceneView.scene.rootNode.addChildNode(boxNode)
    
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
