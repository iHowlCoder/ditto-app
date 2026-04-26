//
//  DNAOrientationTester.swift
//  ditto-hacks
//
//  Interactive tool to find the correct orientation
//

import SwiftUI
import SceneKit

struct DNAOrientationTester: View {
    @State private var rotationX: Double = 0.0  // Start with zero rotation
    @State private var rotationY: Double = 0.0
    @State private var rotationZ: Double = 0.0
    @State private var cameraDistance: Double = 25.0  // Farther back
    @State private var cameraOffsetX: Double = 3.0  // Offset to right
    @State private var cameraOffsetY: Double = 2.0  // Offset upward
    @State private var modelScale: Double = 0.25  // 1/4 scale
    
    var body: some View {
        VStack(spacing: 0) {
            // Fullscreen 3D view
            DNAOrientationSceneView(
                rotationX: Float(rotationX * .pi / 180),
                rotationY: Float(rotationY * .pi / 180),
                rotationZ: Float(rotationZ * .pi / 180),
                cameraDistance: Float(cameraDistance),
                cameraOffsetX: Float(cameraOffsetX),
                cameraOffsetY: Float(cameraOffsetY),
                modelScale: Float(modelScale)
            )
            .ignoresSafeArea()
            
            // Controls overlay at bottom
            VStack(spacing: 15) {
                Text("DNA Orientation Tester")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text("Rotation X: \(Int(rotationX))°")
                        .foregroundColor(.red)
                        .frame(width: 130, alignment: .leading)
                    Slider(value: $rotationX, in: -180...180)
                    Button("0°") { rotationX = 0 }
                        .buttonStyle(.bordered)
                }
                
                HStack {
                    Text("Rotation Y: \(Int(rotationY))°")
                        .foregroundColor(.green)
                        .frame(width: 130, alignment: .leading)
                    Slider(value: $rotationY, in: -180...180)
                    Button("0°") { rotationY = 0 }
                        .buttonStyle(.bordered)
                }
                
                HStack {
                    Text("Rotation Z: \(Int(rotationZ))°")
                        .foregroundColor(.blue)
                        .frame(width: 130, alignment: .leading)
                    Slider(value: $rotationZ, in: -180...180)
                    Button("0°") { rotationZ = 0 }
                        .buttonStyle(.bordered)
                }
                
                HStack {
                    Text("Camera Z: \(Int(cameraDistance))")
                        .foregroundColor(.orange)
                        .frame(width: 130, alignment: .leading)
                    Slider(value: $cameraDistance, in: 5...40)
                }
                
                HStack {
                    Text("Camera X: \(cameraOffsetX, specifier: "%.1f")")
                        .foregroundColor(.cyan)
                        .frame(width: 130, alignment: .leading)
                    Slider(value: $cameraOffsetX, in: -10...10)
                }
                
                HStack {
                    Text("Camera Y: \(cameraOffsetY, specifier: "%.1f")")
                        .foregroundColor(.mint)
                        .frame(width: 130, alignment: .leading)
                    Slider(value: $cameraOffsetY, in: -10...10)
                }
                
                HStack {
                    Text("Scale: \(modelScale, specifier: "%.2f")")
                        .foregroundColor(.purple)
                        .frame(width: 130, alignment: .leading)
                    Slider(value: $modelScale, in: 0.1...1.5)
                }
                
                HStack(spacing: 10) {
                    Button("Reset All") {
                        rotationX = 0
                        rotationY = 0
                        rotationZ = 0
                        cameraDistance = 25
                        cameraOffsetX = 3
                        cameraOffsetY = 2
                        modelScale = 0.25
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Try -90° X") {
                        rotationX = -90
                        rotationY = 0
                        rotationZ = 0
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Try +90° Y") {
                        rotationX = 0
                        rotationY = 90
                        rotationZ = 0
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Try +90° Z") {
                        rotationX = 0
                        rotationY = 0
                        rotationZ = 90
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(Color.black.opacity(0.8))
        }
        .background(Color.black)
    }
}

struct DNAOrientationSceneView: UIViewRepresentable {
    var rotationX: Float
    var rotationY: Float
    var rotationZ: Float
    var cameraDistance: Float
    var cameraOffsetX: Float
    var cameraOffsetY: Float
    var modelScale: Float
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .black
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = true // Allow manual inspection
        sceneView.antialiasingMode = .multisampling4X
        
        context.coordinator.sceneView = sceneView
        setupScene(sceneView: sceneView)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update model orientation and scale
        if let dnaNode = uiView.scene?.rootNode.childNode(withName: "dnaModel", recursively: false) {
            dnaNode.eulerAngles = SCNVector3(rotationX, rotationY, rotationZ)
            dnaNode.scale = SCNVector3(modelScale, modelScale, modelScale)
        }
        
        // Update camera position and angle
        if let cameraNode = uiView.scene?.rootNode.childNode(withName: "camera", recursively: false) {
            cameraNode.position = SCNVector3(Float(cameraOffsetX), Float(cameraOffsetY), Float(cameraDistance))
            cameraNode.look(at: SCNVector3(0, 0, 0))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var sceneView: SCNView?
    }
    
    private func setupScene(sceneView: SCNView) {
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Load DNA model
        if let dnaScene = SCNScene(named: "dna.dae") {
            let dnaNode = dnaScene.rootNode.clone()
            dnaNode.name = "dnaModel"
            
            // Apply materials
            applyMaterialsFromJSON(to: dnaNode)
            
            // Initial setup
            dnaNode.position = SCNVector3(0, 0, 0)
            dnaNode.scale = SCNVector3(modelScale, modelScale, modelScale)
            dnaNode.eulerAngles = SCNVector3(rotationX, rotationY, rotationZ)
            
            scene.rootNode.addChildNode(dnaNode)
            
            print("✅ DNA model loaded for orientation testing")
        } else {
            print("❌ Failed to load dna.dae")
        }
        
        // Lighting
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.4, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = UIColor.white
        directionalLight.light?.intensity = 1200
        directionalLight.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        scene.rootNode.addChildNode(directionalLight)
        
        // Camera - positioned at angle to view model
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 60
        cameraNode.position = SCNVector3(Float(cameraOffsetX), Float(cameraOffsetY), Float(cameraDistance))
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func applyMaterialsFromJSON(to node: SCNNode) {
        guard let url = Bundle.main.url(forResource: "main.materials", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        
        node.enumerateChildNodes { childNode, _ in
            if let geometry = childNode.geometry {
                for (index, existingMaterial) in geometry.materials.enumerated() {
                    let materialName = existingMaterial.name ?? "unnamed_\(index)"
                    
                    if let materialData = json[materialName] as? [String: Any],
                       let stages = materialData["Stages"] as? [[String: Any]],
                       let firstStage = stages.first,
                       let baseColorArray = firstStage["baseColorFactor"] as? [Double] {
                        
                        let material = SCNMaterial()
                        material.name = materialName
                        material.lightingModel = .physicallyBased
                        material.diffuse.contents = UIColor(
                            red: CGFloat(baseColorArray[0]),
                            green: CGFloat(baseColorArray[1]),
                            blue: CGFloat(baseColorArray[2]),
                            alpha: CGFloat(baseColorArray[3])
                        )
                        
                        if let metallic = firstStage["metallicFactor"] as? Double {
                            material.metalness.contents = metallic
                        }
                        
                        if let roughness = firstStage["roughnessFactor"] as? Double {
                            material.roughness.contents = roughness
                        }
                        
                        material.isDoubleSided = true
                        geometry.materials[index] = material
                    } else {
                        existingMaterial.isDoubleSided = true
                    }
                }
            }
        }
    }
}

#Preview("iPhone 17 Pro") {
    DNAOrientationTester()
        .previewDevice(PreviewDevice(rawValue: "iPhone 16 Pro"))
        .previewDisplayName("iPhone 17 Pro Simulation")
}
