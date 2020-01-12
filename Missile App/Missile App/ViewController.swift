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
        
        //CREATING MISSILE SCENE
        let missleScene = SCNScene(named: "art.scnassets/missile-1.scn")
        let missile = Missile(scene: missleScene!)
        missile.name = "Missile"
        
        
        //let missleNode = missleScene?.rootNode.childNode(withName: "missile", recursively: true)
        //missleNode?.position = SCNVector3(0,0,-0.5)


        // Create a new scene
        let scene = SCNScene()
        scene.rootNode.addChildNode(missile)
        
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
        //are you touching missile
        guard let missileNode = self.sceneView.scene.rootNode.childNode(withName: "Missile", recursively: true) else {
            fatalError("Missile Not Found")
        }
        
        //Accessing smokeNode
        guard let smokeNode = missileNode.childNode(withName: "smokeNode", recursively: true) else {
            fatalError("smoke Not Found")
        }
        //removing smokeNode to add fire for departing
        smokeNode.removeAllParticleSystems()
        
        //adding fire particle
        let fire = SCNParticleSystem(named: "fire.scnp", inDirectory: nil)
        smokeNode.addParticleSystem(fire!)
        
        
        
        
        
        
        missileNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil) //dynamic to move
        missileNode.physicsBody?.isAffectedByGravity = false //if it is true it will fall down we want to fire it up
        missileNode.physicsBody?.damping = 0.0 //air fiction is 0 to go infinitiy
        
        missileNode.physicsBody?.applyForce(SCNVector3(0,80,0), asImpulse: false) //asImpluse is like kicking it we want to accelerate so false , 0,10,0 means go in y diection to up
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
