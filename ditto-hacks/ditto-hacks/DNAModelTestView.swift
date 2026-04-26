//
//  DNAModelTestView.swift
//  ditto-hacks
//
//  Test view to verify DNA model loading and rotation
//

import SwiftUI
import SceneKit

struct DNAModelTestView: View {
    @State private var rotationSpeed: Double = 4.0
    @State private var tiltX: Double = 30.0
    @State private var tiltY: Double = 45.0
    
    var body: some View {
        VStack {
            Text("DNA Model Test")
                .font(.title)
                .padding()
            
            DNATestSceneView(
                rotationSpeed: rotationSpeed,
                tiltX: Float(tiltX * .pi / 180),
                tiltY: Float(tiltY * .pi / 180)
            )
            .frame(height: 400)
            .background(Color.black)
            .cornerRadius(20)
            .padding()
            
            VStack(spacing: 20) {
                VStack {
                    Text("Rotation Speed: \(rotationSpeed, specifier: "%.1f")s")
                    Slider(value: $rotationSpeed, in: 1...10)
                }
                
                VStack {
                    Text("Tilt X: \(tiltX, specifier: "%.0f")°")
                    Slider(value: $tiltX, in: 0...90)
                }
                
                VStack {
                    Text("Tilt Y: \(tiltY, specifier: "%.0f")°")
                    Slider(value: $tiltY, in: 0...360)
                }
            }
            .padding()
        }
    }
}

struct DNATestSceneView: UIViewRepresentable {
    var rotationSpeed: Double
    var tiltX: Float
    var tiltY: Float
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .black
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = true // Allow manual rotation for testing
        sceneView.antialiasingMode = .multisampling4X
        
        context.coordinator.sceneView = sceneView
        setupScene(sceneView: sceneView)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update rotation speed and tilt when sliders change
        if let dnaNode = uiView.scene?.rootNode.childNode(withName: "dnaModel", recursively: false) {
            // Update tilt
            dnaNode.eulerAngles = SCNVector3(tiltX, tiltY, 0)
            
            // Update rotation animation
            dnaNode.removeAnimation(forKey: "rotation")
            let rotation = CABasicAnimation(keyPath: "rotation")
            rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
            rotation.duration = rotationSpeed
            rotation.repeatCount = .infinity
            dnaNode.addAnimation(rotation, forKey: "rotation")
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
            
            // Initial rotation and position
            dnaNode.position = SCNVector3(0, 0, 0)
            dnaNode.eulerAngles = SCNVector3(tiltX, tiltY, 0)
            
            // Add rotation animation
            let rotation = CABasicAnimation(keyPath: "rotation")
            rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
            rotation.duration = rotationSpeed
            rotation.repeatCount = .infinity
            dnaNode.addAnimation(rotation, forKey: "rotation")
            
            scene.rootNode.addChildNode(dnaNode)
            
            print("✅ DNA model loaded successfully")
        } else {
            print("❌ Failed to load dna.dae")
            
            // Add fallback geometry
            let box = SCNBox(width: 1, height: 2, length: 1, chamferRadius: 0)
            box.firstMaterial?.diffuse.contents = UIColor.red
            let boxNode = SCNNode(geometry: box)
            boxNode.name = "dnaModel"
            boxNode.eulerAngles = SCNVector3(tiltX, tiltY, 0)
            scene.rootNode.addChildNode(boxNode)
        }
        
        // Lighting
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.3, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = UIColor.white
        directionalLight.light?.intensity = 1000
        directionalLight.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        scene.rootNode.addChildNode(directionalLight)
        
        // Accent lights from materials
        addAccentLights(to: scene)
        
        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 10)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func applyMaterialsFromJSON(to node: SCNNode) {
        guard let url = Bundle.main.url(forResource: "main.materials", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("⚠️ Failed to load main.materials.json")
            return
        }
        
        node.enumerateChildNodes { childNode, _ in
            if let geometry = childNode.geometry {
                if let materialName = geometry.firstMaterial?.name,
                   let materialData = json[materialName] as? [String: Any],
                   let stages = materialData["Stages"] as? [[String: Any]],
                   let firstStage = stages.first,
                   let baseColorArray = firstStage["baseColorFactor"] as? [Double] {
                    
                    let material = SCNMaterial()
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
                    geometry.firstMaterial = material
                    
                    print("✅ Applied material: \(materialName) - RGB(\(baseColorArray[0]), \(baseColorArray[1]), \(baseColorArray[2]))")
                }
            }
        }
    }
    
    private func addAccentLights(to scene: SCNScene) {
        let greenLight = SCNNode()
        greenLight.light = SCNLight()
        greenLight.light?.type = .omni
        greenLight.light?.color = UIColor(red: 0.0, green: 0.735, blue: 0.007, alpha: 1.0)
        greenLight.light?.intensity = 300
        greenLight.position = SCNVector3(-5, 2, 5)
        scene.rootNode.addChildNode(greenLight)
        
        let yellowLight = SCNNode()
        yellowLight.light = SCNLight()
        yellowLight.light?.type = .omni
        yellowLight.light?.color = UIColor(red: 0.704, green: 0.735, blue: 0.002, alpha: 1.0)
        yellowLight.light?.intensity = 300
        yellowLight.position = SCNVector3(5, -2, 5)
        scene.rootNode.addChildNode(yellowLight)
        
        let pinkLight = SCNNode()
        pinkLight.light = SCNLight()
        pinkLight.light?.type = .omni
        pinkLight.light?.color = UIColor(red: 0.735, green: 0.024, blue: 0.549, alpha: 1.0)
        pinkLight.light?.intensity = 200
        pinkLight.position = SCNVector3(0, 3, -3)
        scene.rootNode.addChildNode(pinkLight)
    }
}

#Preview {
    DNAModelTestView()
}
