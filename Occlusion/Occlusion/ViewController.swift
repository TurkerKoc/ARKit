//
//  ViewController.swift
//  Occlusion
//
//  Created by Mohammad Azam on 11/4/17.
//  Copyright © 2017 Mohammad Azam. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    private var planes :[Plane] = [Plane]()
    private var road1 = [SCNNode]()
    var isButtonClicked :Bool = false
    private var cameraPos :GLKVector3!
    private var nodePositions = [GLKVector3]()
    private var distanceBetweenNodesAndCamera = [Float]()
    
    private lazy var road1Button :UIButton = {
        
        let button = UIButton(type: .custom)
        button.setTitle("Kitchen", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor(red: 53/255, green: 73/255, blue: 94/255, alpha: 1)
        button.addTarget(self, action: #selector(showRoad1), for: .touchUpInside)
        return button
        
    }()
    
    
    @objc func showRoad1()
    {
//        guard let currentFrame = self.sceneView.session.currentFrame else {
//            return
//        }
//
//        var translation = matrix_identity_float4x4
//        translation.columns.3.z = -0.5
//
//        // get the arrow
//        let arrowScene = SCNScene(named: "arrow")!
//        let arrowNode = arrowScene.rootNode.childNode(withName: "arr", recursively: true)!
//        arrowNode.simdTransform =  matrix_multiply(currentFrame.camera.transform, translation)
//        arrowNode.scale = SCNVector3(0.05,0.05,0.05)
//
//
////        let newAngleX = Float(-90) * (Float) (Double.pi)/180
////        arrowNode.eulerAngles.x += newAngleX
////
////        let newAngleZ = Float(90) * (Float) (Double.pi)/180
////        arrowNode.eulerAngles.z += newAngleZ
//
//
//        self.sceneView.scene.rootNode.addChildNode(arrowNode)
//
//        translation.columns.3.z -= 0.5
//        let arrowNode2 = arrowNode.clone()
//        arrowNode2.simdTransform =  matrix_multiply(currentFrame.camera.transform, translation)
//        arrowNode2.scale = SCNVector3(0.05,0.05,0.05)
//
//        //self.sceneView.scene.rootNode.addChildNode(arrowNode2)
        
        
        
        
        isButtonClicked = true
        
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = 0.5
    
        for i in 0..<3
        {
            road1[i].simdTransform =  matrix_multiply(currentFrame.camera.transform, translation)
            translation.columns.3.z += 0.5
        }
        for i in 3..<14
        {
            road1[i].simdTransform =  matrix_multiply(currentFrame.camera.transform, translation)
            translation.columns.3.y += 0.5
        }
        translation.columns.3.y -= 0.5
        translation.columns.3.z -= 0.5
        road1[14].simdTransform =  matrix_multiply(currentFrame.camera.transform, translation)
        for i in 0..<15
        {
            self.sceneView.scene.rootNode.addChildNode(road1[i])
        }
        let text = SCNText(string: "REACHED",extrusionDepth:  1.0) //extrusion means how much depth you want in your text
        text.firstMaterial?.diffuse.contents = UIColor.red //in box we used Material but for texts there is only one side so we can use firstMaterial
        
        translation.columns.3.z -= 0.5
        translation.columns.3.y -= 0.7
        let textNode = SCNNode(geometry: text) //assigning geomtery
        textNode.simdTransform =  matrix_multiply(currentFrame.camera.transform, translation)
        textNode.eulerAngles = SCNVector3Make(.pi, .pi, .pi)
        textNode.scale = SCNVector3(0.02,0.02, 0.02) //scaling it because it really big
        self.sceneView.scene.rootNode.addChildNode(textNode)
        
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        self.sceneView.autoenablesDefaultLighting = true 
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let dir1 = SCNSphere(radius: 0.06)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dir1.materials = [material]
        for i in 0..<15
        {
            road1.append(SCNNode(geometry: dir1))
        }
        for i in 0..<15
        {
            distanceBetweenNodesAndCamera.append(0.0)
        }
        for i in 0..<15
        {
            nodePositions.append(SCNVector3ToGLKVector3(self.sceneView.scene.rootNode.childNodes[0].presentation.worldPosition))
        }
        setupUI()
        registerGestureRecognizers()
    }

    private func setupUI() {
        
        self.view.addSubview(self.road1Button)
        
        // add constraints to save world map button
        self.road1Button.centerXAnchor.constraint(equalTo: self.sceneView.centerXAnchor).isActive = true
        self.road1Button.bottomAnchor.constraint(equalTo: self.sceneView.bottomAnchor, constant: -20).isActive = true
        self.road1Button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.road1Button.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        let plane = Plane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    //function for finding distance between nodes and camera and making closest one green
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        self.cameraPos = SCNVector3ToGLKVector3(self.sceneView.scene.rootNode.childNodes[0].presentation.worldPosition)
        for i in 0..<15
        {
            if(isButtonClicked)
            {
                self.nodePositions[i] = SCNVector3ToGLKVector3(self.road1[i].presentation.worldPosition)
            }
        }
        for i in 0..<15
        {
            if(isButtonClicked)
            {
                distanceBetweenNodesAndCamera[i] = GLKVector3Distance(self.cameraPos,self.nodePositions[i])
            }
        }
//        let minDistanceNode = distanceBetweenNodesAndCamera.min()
        print("Node positions: ",nodePositions)
        print("Distances: ",distanceBetweenNodesAndCamera)
        
        var position = distanceBetweenNodesAndCamera.index(of: distanceBetweenNodesAndCamera.min()!)
        
        print("min pos index: ",position)
//        let nodePos = SCNVector3ToGLKVector3(road1[0].presentation.worldPosition)
//        let node2Pos = SCNVector3ToGLKVector3(road1[1].presentation.worldPosition)
//        let distance = GLKVector3Distance(cameraPos,nodePos)
//        let distance2 = GLKVector3Distance(cameraPos,node2Pos)
//        print("Distance 1: ",distance)
//        print("Distance 2: ",distance2)
        
        //let nodePositions = [GLKVector3]()
        
        if(isButtonClicked)
        {
            let dir1 = SCNSphere(radius: 0.06)
            
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.green
            dir1.materials = [material]
            road1[position!].geometry = dir1
        }
        //print("CHİLD NODES: ",self.sceneView.scene.rootNode.childNodes[0].presentation.worldPosition)
        
        
    }
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer :UITapGestureRecognizer) {
       
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        
        // get the arrow
        let arrowScene = SCNScene(named: "arrow")!
        let arrowNode = arrowScene.rootNode.childNode(withName: "arr", recursively: true)!
        arrowNode.simdTransform =  matrix_multiply(currentFrame.camera.transform, translation)
        arrowNode.scale = SCNVector3(0.05,0.05,0.05)
    
        self.sceneView.scene.rootNode.addChildNode(arrowNode)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        if #available(iOS 11.3, *) {
            configuration.planeDetection = .vertical
        } else {
            // Fallback on earlier versions
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

}
