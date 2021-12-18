//
//  Globals.swift
//  WorldScan
//
//  Created by Larry Li on 12/16/21.
//
import ARKit

var defaultConfiguration: ARWorldTrackingConfiguration {
    let configuration = ARWorldTrackingConfiguration()
    configuration.sceneReconstruction = .mesh
    configuration.environmentTexturing = .automatic
    // configuration.wantsHDREnvironmentTextures = true
    if type(of: configuration).supportsFrameSemantics(.sceneDepth) {
       configuration.frameSemantics = .sceneDepth
    }
    return configuration
}
