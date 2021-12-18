//
//  ViewController.swift
//  WorldScan
//
//  Created by Larry Li on 12/16/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet var scanBtn: UIButton!
    
    let coachingOverlay = ARCoachingOverlayView()

    /// Set scan or stop
    private func setScanSelect(select: Bool) {
        if select {  // start scan
            sceneView.session.run(defaultConfiguration)
            scanBtn.isSelected = true
        }
        else {  // start scan
            self.sceneView.session.pause()
            scanBtn.isSelected = false
        }
    }
    
       
    ///  onScanBtn - toggle between select
    @IBAction func onScanBtn(_ sender: UIButton) {
        setScanSelect(select: !sender.isSelected)
    }
    
    
    ///  viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the Scan button
        let stopScanBtn = UIImage(named: "stopScanBtn")!.resize(size: CGSize(width:80, height:80))
        let startScanBtn = UIImage(named: "startScanBtn")!.resize(size: CGSize(width:80, height:80))
        scanBtn.setImage(stopScanBtn, for: .selected)
        scanBtn.setImage(startScanBtn, for: .normal)
                
        // Configure the ARSCNView
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        
        // Coaching overlay
        setupCoachingOverlay()
    }
    
    
    ///  viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start scanning
        setScanSelect(select: true)
    }
    
    
    ///  viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    /// Create a SCNGeometry based on ARFrame and ARMeshAnchor and node
    func scanGeometory(frame: ARFrame, anchor: ARMeshAnchor, needTexture: Bool = false, cameraImage: UIImage? = nil) -> SCNGeometry {

        let camera = frame.camera

        let geometry = SCNGeometry(geometry: anchor.geometry, camera: camera, modelMatrix: anchor.transform, needTexture: needTexture)

        if let image = cameraImage, needTexture {
            geometry.firstMaterial?.diffuse.contents = image
        } else {
            geometry.firstMaterial?.diffuse.contents = UIColor(red: 0.5, green: 1.0, blue: 0.0, alpha: 0.7)
        }
        return geometry
    }
    
    
    ///  Update all nodes in the scene with their latest texture and mesh
    func scanAllGeometry(needTexture: Bool) {
        guard let frame = sceneView.session.currentFrame else { return }
        guard let cameraImage = captureCamera() else {return}

        guard let anchors = sceneView.session.currentFrame?.anchors else { return }
        let meshAnchors = anchors.compactMap { $0 as? ARMeshAnchor}
        for anchor in meshAnchors {
            guard let node = sceneView.node(for: anchor) else { continue }
            let geometry = scanGeometory(frame: frame, anchor: anchor, needTexture: needTexture, cameraImage: cameraImage)
            node.geometry = geometry
        }
    }
    
    ///  Capture current frame image and convert it to UIImage required for texture
    func captureCamera() -> UIImage? {
        guard let frame = sceneView.session.currentFrame else {return nil}

        let pixelBuffer = frame.capturedImage

        let image = CIImage(cvPixelBuffer: pixelBuffer)

        let context = CIContext(options:nil)
        guard let cameraImage = context.createCGImage(image, from: image.extent) else {return nil}

        return UIImage(cgImage: cameraImage)
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    
    ///  Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let meshAnchor = anchor as? ARMeshAnchor,
              let frame = sceneView.session.currentFrame else { return nil }
        
        let node = SCNNode()
        let geometry = self.scanGeometory(frame: frame, anchor: meshAnchor)
        node.geometry = geometry
        return node
    }
    
    
    ///  Update the node geometry with the latest mesh anchor update
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let frame = self.sceneView.session.currentFrame else { return }
        guard let anchor = anchor as? ARMeshAnchor else { return }
        let geometry = self.scanGeometory(frame: frame, anchor: anchor)
        node.geometry = geometry
    }
    
    
    ///  Called periodically to update all nodes with latest mesh
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.scanAllGeometry(needTexture: true)
    }
      
    
    // MARK: - ARSessionDelegate

    ///  This is called when a new frame has been updated.
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }

    
   
    ///  This is called when new anchors are added to the session.
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        let meshAnchors = anchors.compactMap({ $0 as? ARMeshAnchor })
        print("Session - didAdd \(meshAnchors.count) meshes")
    }

    
    ///  This is called when anchors are updated.
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        let meshAnchors = anchors.compactMap({ $0 as? ARMeshAnchor })
        print("Session - didUpdate \(meshAnchors.count) meshes")
    }

    
    ///  This is called when anchors are removed from the session.
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        let meshAnchors = anchors.compactMap({ $0 as? ARMeshAnchor })
        print("Session - didRemove \(meshAnchors.count) meshes")
    }
    
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}


extension ViewController: ARCoachingOverlayViewDelegate {
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    }

    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    }

    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
    }

    func setupCoachingOverlay() {
        // Set up coaching view
        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
}


