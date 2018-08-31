//
//  ViewController.swift
//  ShootingApp
//
//  Created by Aishvi Vivek Shah on 31/8/18.
//  Copyright © 2018 Aishvi Vivek Shah. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum BoxBodyType : Int
{
    case bullet = 1
    case barrier = 2
}

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate
{
    @IBOutlet var sceneView: ARSCNView!
    var lastContactNode :SCNNode!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()
        let box1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        box1.materials = [material]
        
        let box1Node = SCNNode(geometry: box1)
        box1Node.name = "Barrier1"
        box1Node.position = SCNVector3(0,0,-0.5)
        box1Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box1Node.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        
        let box2Node = SCNNode(geometry: box1)
        box2Node.name = "Barrier2"
        box2Node.position = SCNVector3(-0.2,0,-0.5)
        box2Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box2Node.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        
        let box3Node = SCNNode(geometry: box1)
        box3Node.name = "Barrier3"
        box3Node.position = SCNVector3(0.2,0,-0.5)
        box3Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box3Node.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        
        scene.rootNode.addChildNode(box1Node)
        scene.rootNode.addChildNode(box2Node)
        scene.rootNode.addChildNode(box3Node)
        
        sceneView.scene = scene
        self.sceneView.scene.physicsWorld.contactDelegate = self
        registerTapGestureRecognizer()
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact)
    {
        var contactNode :SCNNode!
        if contact.nodeA.name == "Bullet"
        {
            contactNode = contact.nodeB
        }
        else
        {
            contactNode = contact.nodeA
        }
        if self.lastContactNode != nil && self.lastContactNode == contactNode
        {
            return
        }
        self.lastContactNode = contactNode
        
        let box1 = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        box1.materials = [material]
        
        self.lastContactNode.geometry?.materials = [material]
    }
    private func registerTapGestureRecognizer()
    {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shootItems))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func shootItems(recognizer :UITapGestureRecognizer)
    {
        guard let currentFrame = self.sceneView.session.currentFrame
        else
        {
            return
        }
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.3
        
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        box.materials = [material]
        
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "Bullet"
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        boxNode.physicsBody?.isAffectedByGravity = false
        boxNode.physicsBody?.categoryBitMask = BoxBodyType.bullet.rawValue
        boxNode.physicsBody?.contactTestBitMask = BoxBodyType.barrier.rawValue
        boxNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        let forceVector = SCNVector3(boxNode.worldFront.x * 2,boxNode.worldFront.y * 2, boxNode.worldFront.z * 2)
        boxNode.physicsBody?.applyForce(forceVector, asImpulse: true)
        self.sceneView.scene.rootNode.addChildNode(boxNode)
        
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    
        sceneView.session.pause()
    }
}
