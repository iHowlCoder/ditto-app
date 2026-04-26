//
//  AvatarSceneView.swift
//  ditto-hacks
//
//  Created by Sudhit Muppa on 4/25/26.
//

import SwiftUI
import SceneKit

struct AvatarSceneView: UIViewRepresentable {
    let score: Float  // 0.0 to 1.0 - determines which model to show
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.09, alpha: 1.0)
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = false
        scnView.scene = makeScene()
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update scene when score changes
        uiView.scene = makeScene()
    }

    // MARK: - Scene Setup
    private func makeScene() -> SCNScene {
        let scene = SCNScene()

        // Camera - positioned to view upright human from slight angle
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 45 // Adjust field of view for better framing
        cameraNode.position = SCNVector3(2, 1.0, 4) // Slightly to the side and front
        cameraNode.look(at: SCNVector3(0, 0.8, 0)) // Look at upper body area
        scene.rootNode.addChildNode(cameraNode)

        // Ambient light
        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.light?.color = UIColor(white: 0.3, alpha: 1.0)
        scene.rootNode.addChildNode(ambientNode)

        // Main directional light
        let mainLightNode = SCNNode()
        mainLightNode.light = SCNLight()
        mainLightNode.light?.type = .directional
        mainLightNode.light?.color = UIColor.white
        mainLightNode.light?.intensity = 1500
        mainLightNode.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        scene.rootNode.addChildNode(mainLightNode)

        // Green rim light
        let rimLightNode = SCNNode()
        rimLightNode.light = SCNLight()
        rimLightNode.light?.type = .directional
        rimLightNode.light?.color = UIColor(red: 0.0, green: 0.9, blue: 0.4, alpha: 1.0)
        rimLightNode.light?.intensity = 400
        rimLightNode.eulerAngles = SCNVector3(0, -Float.pi / 2, 0)
        scene.rootNode.addChildNode(rimLightNode)

        // Add the single avatar based on score
        scene.rootNode.addChildNode(makeAvatar())

        return scene
    }

    // MARK: - Avatar
    private func makeAvatar() -> SCNNode {
        // If score > 0.6, show upright human model
        // Otherwise show bad posture model
        let modelName = score > 0.6 ? "human" : "badhuman"
        return loadModel(named: modelName)
    }

    // MARK: - Load DAE Model
    private func loadModel(named modelName: String) -> SCNNode {
        let containerNode = SCNNode()
        containerNode.position = SCNVector3(0, 0, 0)
        
        // Try to load the .dae file
        if let scene = SCNScene(named: "\(modelName).dae") {
            print("✅ Loaded model: \(modelName).dae for score: \(score)")
            
            // Get the root node and add it
            let modelNode = scene.rootNode.clone()
            
            // Rotate -90 degrees around X-axis to correct orientation
            modelNode.eulerAngles.x = -Float.pi / 2  // -90 degrees
            
            // Scale the model to fit nicely in the small card
            modelNode.scale = SCNVector3(1.0, 1.0, 1.0)
            
            // Center the model vertically
            let (min, max) = modelNode.boundingBox
            let height = max.y - min.y
            modelNode.position = SCNVector3(0, -height / 2, 0)
            
            containerNode.addChildNode(modelNode)
            
            // Add Y-axis rotation animation (spin upright like a turntable)
            let spin = CABasicAnimation(keyPath: "rotation")
            spin.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))  // Y-axis rotation (vertical)
            spin.duration = 8.0
            spin.repeatCount = .infinity
            containerNode.addAnimation(spin, forKey: "yAxisSpin")
            
        } else {
            // Fallback to placeholder if model doesn't exist
            print("⚠️ Could not load \(modelName).dae - using placeholder (score: \(score))")
            let fallbackNode = makePlaceholder()
            containerNode.addChildNode(fallbackNode)
        }
        
        return containerNode
    }

    // MARK: - Placeholder (if models don't load)
    private func makePlaceholder() -> SCNNode {
        // Create a simple humanoid shape as fallback
        let geometry = SCNBox(width: 0.8, height: 2.0, length: 0.4, chamferRadius: 0.1)
        
        let material = SCNMaterial()
        if score > 0.6 {
            // Good score = green
            material.diffuse.contents = UIColor(red: 0.0, green: 0.9, blue: 0.4, alpha: 1.0)
            material.emission.contents = UIColor(red: 0.0, green: 0.3, blue: 0.1, alpha: 1.0)
        } else {
            // Bad score = red
            material.diffuse.contents = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        material.metalness.contents = NSNumber(value: 0.7)
        material.roughness.contents = NSNumber(value: 0.3)
        material.lightingModel = .physicallyBased
        geometry.materials = [material]
        
        let node = SCNNode(geometry: geometry)
        
        // Y-axis spin for placeholder too (upright rotation)
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))  // Y-axis rotation
        spin.duration = 8.0
        spin.repeatCount = .infinity
        node.addAnimation(spin, forKey: "yAxisSpin")
        
        return node
    }
}
