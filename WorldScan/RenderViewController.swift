//
//  RenderViewController.swift
//  WorldScan
//
//  Created by Larry Li on 12/18/21.
//

import UIKit
import SceneKit
import ARKit

class RenderViewController: UIViewController, SCNSceneRendererDelegate {
   
    @IBOutlet var sceneView: SCNView!
    var scene: SCNScene!
    var cameraNode: SCNNode!
    
    
    /// Create scene
    func createScene() {
        
        
    }
    
    
    /// Clear the scene nodes
    func clearScene() {
        for node in scene.rootNode.childNodes {
            node.removeFromParentNode()
        }
    }
    
    ///  viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup view
        sceneView.showsStatistics = true
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        
        // Setup scene
        scene = SCNScene()
        scene.background.contents = UIColor.black
        sceneView.scene = scene
        
        // Setup camera
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x:0, y:5, z: 10)
        scene.rootNode.addChildNode(cameraNode)
    }
    
    
    ///  viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
     
    }
    
    
    ///  viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    
    // Implement this to perform per-frame game logic.  Called exactly once per
    // frame before any animation and actions are evaluated and any physics
    // are simulated.
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let map = worldMap {
            let meshAnchors = map.anchors.compactMap({ $0 as? ARMeshAnchor })
            let probeAnchors = map.anchors.compactMap({ $0 as? AREnvironmentProbeAnchor })
            print("worldMap has \(meshAnchors.count) meshAnchors  \(probeAnchors.count) probeAnchors")
        }
    }

    /// Invoked on the delegate once the scene renderer did apply the animations.
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
    }
        

    
    /// Invoked on the delegate once the scene renderer did simulate the physics.
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
    }

    
    /// Invoked on the delegate once the scene renderer did apply the constraints.
    @available(iOS 11.0, *)
    func renderer(_ renderer: SCNSceneRenderer, didApplyConstraintsAtTime time: TimeInterval) {
    }

    
    /// Invoked on the delegate before the scene renderer renders the scene. At this point the openGL
    /// context and the destination framebuffer are bound.
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
    }

    
    /// Invoked on the delegate once the scene renderer did render the scene.
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
    }
}

