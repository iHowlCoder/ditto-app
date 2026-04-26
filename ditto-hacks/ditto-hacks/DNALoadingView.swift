//
//  DNALoadingView.swift
//  ditto-hacks
//
//  Created on 4/25/26.
//

import SwiftUI
import SceneKit

struct DNALoadingView: View {
    @Binding var isLoadingComplete: Bool
    @State private var revealProgress: Double = 0
    @State private var glowPulse = false
    @State private var particleOffset: CGFloat = 0
    @State private var gradientRotation: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.0, blue: 0.15),
                        Color(red: 0.1, green: 0.0, blue: 0.25),
                        Color(red: 0.0, green: 0.1, blue: 0.2),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .hueRotation(.degrees(gradientRotation))
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                        gradientRotation = 360
                    }
                }
                
                // Particle effect layer
                ZStack {
                    ForEach(0..<30, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: CGFloat.random(in: 2...6))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .offset(y: particleOffset)
                            .animation(
                                .linear(duration: Double.random(in: 3...8))
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.1),
                                value: particleOffset
                            )
                    }
                }
                .onAppear {
                    particleOffset = -geometry.size.height
                }
                
                // 3D DNA viewport
                DNASceneView()
                    .ignoresSafeArea()
                    .onAppear {
                        // Wait 3 seconds then mark loading as complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation {
                                isLoadingComplete = true
                            }
                        }
                    }
                
                // Radial glow effect behind text
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .scaleEffect(glowPulse ? 1.2 : 1.0)
                    .opacity(glowPulse ? 0.6 : 0.3)
                    .blur(radius: 30)
                    .offset(y: -geometry.size.height / 2 + 120)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            glowPulse = true
                        }
                    }
            
            // Extravagant animated app name with reveal effect
            VStack {
                ZStack {
                    // Main text with vertical slice reveal
                    HStack(spacing: 2) {
                        ForEach(Array("DITTO".enumerated()), id: \.offset) { index, char in
                            Text(String(char))
                                .font(.system(size: 64, weight: .heavy, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.0, green: 0.9, blue: 0.4),
                                            Color(red: 0.4, green: 1.0, blue: 0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.8), radius: 20, x: 0, y: 0)
                                .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.6), radius: 40, x: 0, y: 0)
                                .mask(
                                    Rectangle()
                                        .offset(y: revealProgress < 0.5 ? 32 * (1 - min(1, revealProgress * 4)) : 0)
                                        .frame(height: revealProgress < 0.5 ? 64 * min(1, revealProgress * 4) : 64)
                                )
                                .opacity(revealProgress < 0.5 ? min(1, revealProgress * 4) : 1)
                                .scaleEffect(revealProgress >= 0.5 ? 1.0 : 0.8 + (revealProgress * 0.4))
                                .animation(
                                    .spring(response: 0.8, dampingFraction: 0.7)
                                    .delay(Double(index) * 0.08),
                                    value: revealProgress
                                )
                        }
                    }
                    
                    // Shimmer effect (only appears after full reveal)
                    if revealProgress >= 0.5 {
                        HStack(spacing: 2) {
                            ForEach(Array("DITTO".enumerated()), id: \.offset) { index, char in
                                Text(String(char))
                                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.0),
                                                Color.white.opacity(0.8),
                                                Color.white.opacity(0.0)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .offset(x: glowPulse ? 100 : -100)
                                    .mask(
                                        Text(String(char))
                                            .font(.system(size: 64, weight: .heavy, design: .rounded))
                                    )
                            }
                        }
                        .animation(
                            .linear(duration: 2)
                            .repeatForever(autoreverses: false),
                            value: glowPulse
                        )
                    }
                }
                .padding(.top, 60)
                .onAppear {
                    // First 2 seconds: reveal animation (0 to 0.5)
                    withAnimation(.easeOut(duration: 2)) {
                        revealProgress = 0.5
                    }
                    // After 2 seconds: hold at full display (0.5 to 1.0) then repeat
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.linear(duration: 0.1)) {
                            revealProgress = 1.0
                        }
                        // Restart the cycle every 4 seconds
                        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
                            revealProgress = 0
                            withAnimation(.easeOut(duration: 2)) {
                                revealProgress = 0.5
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.linear(duration: 0.1)) {
                                    revealProgress = 1.0
                                }
                            }
                        }
                    }
                }
                
                // Subtitle with fade animation
                Text("Analyzing Your DNA")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 8)
                    .opacity(glowPulse ? 1.0 : 0.4)
                
                Spacer()
            }
        }
        }
    }
}

struct DNASceneView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .black
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = false
        sceneView.antialiasingMode = .multisampling4X
        
        // Create scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Load DNA model
        if let dnaScene = SCNScene(named: "dna.dae") {
            // Get the root node from the DAE file
            let dnaNode = dnaScene.rootNode.clone()
            
            // Apply materials from JSON (now with double-sided rendering)
            applyMaterialsFromJSON(to: dnaNode)
            
            // Scale the model down so the ENTIRE helix is visible
            dnaNode.scale = SCNVector3(0.18, 0.18, 0.18)
            
            // Position model at origin (centered in screen)
            dnaNode.position = SCNVector3(0, 0, 0)
            
            // NO rotation on the DNA node itself - keep it upright
            dnaNode.eulerAngles = SCNVector3(0, 0, 0)
            
            // Add continuous rotation animation directly to the DNA node
            // The ENTIRE DNA spins around its own vertical center axis (Y-axis)
            let rotationAnimation = CABasicAnimation(keyPath: "rotation")
            rotationAnimation.toValue = NSValue(scnVector4: SCNVector4(0, 0, 1, Float.pi * 2)) // Rotate around Y-axis (vertical center)
            rotationAnimation.duration = 6.0 // 6 seconds for full rotation
            rotationAnimation.repeatCount = .infinity
            dnaNode.addAnimation(rotationAnimation, forKey: "twist")
            
            scene.rootNode.addChildNode(dnaNode)
            
            // Enable baked animation from the DAE file
            // SceneKit automatically plays animations embedded in the DAE
            if !dnaNode.animationKeys.isEmpty {
                print("✅ Found \(dnaNode.animationKeys.count) animations in DAE file")
                // Animations will play automatically
            } else {
                print("⚠️ No animations found in root node, checking children...")
                dnaNode.enumerateChildNodes { childNode, _ in
                    if !childNode.animationKeys.isEmpty {
                        print("✅ Found animations in child node: \(childNode.name ?? "unnamed")")
                    }
                }
            }
            
            // Debug: print the model's bounding box
            let (min, max) = dnaNode.boundingBox
            print("🔍 DNA Model bounding box:")
            print("   Min: (\(min.x), \(min.y), \(min.z))")
            print("   Max: (\(max.x), \(max.y), \(max.z))")
            print("   Width (X): \(max.x - min.x)")
            print("   Height (Y): \(max.y - min.y)")
            print("   Depth (Z): \(max.z - min.z)")
        } else {
            // Fallback: create a simple placeholder if DAE fails to load
            print("⚠️ Failed to load dna.dae, using placeholder")
            let fallbackNode = createFallbackDNA()
            scene.rootNode.addChildNode(fallbackNode)
        }
        
        // Add lighting
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.4, alpha: 1.0) // Slightly brighter
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = UIColor.white
        directionalLight.light?.intensity = 1200 // Increased brightness
        directionalLight.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        scene.rootNode.addChildNode(directionalLight)
        
        // Add colorful accent lights based on materials
        addAccentLights(to: scene)
        
        // Setup camera with wider view to see entire DNA
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 65 // Wider FOV to see entire helix
        
        // Position camera further back to see full DNA
        cameraNode.position = SCNVector3(0, 5, 1)  // Centered, pulled back more
        
        // Look at the DNA model center
        cameraNode.look(at: SCNVector3(0, 0, 6))
        
        scene.rootNode.addChildNode(cameraNode)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    private func applyMaterialsFromJSON(to node: SCNNode) {
        // Parse the materials JSON
        guard let url = Bundle.main.url(forResource: "main.materials", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("⚠️ Failed to load main.materials.json")
            return
        }
        
        print("🎨 Starting material application...")
        print("📦 JSON contains \(json.keys.count) material definitions")
        
        // Apply materials to all child nodes
        node.enumerateChildNodes { childNode, _ in
            if let geometry = childNode.geometry {
                print("🔍 Found geometry with \(geometry.materials.count) material(s)")
                
                // Process each material in the geometry
                for (index, existingMaterial) in geometry.materials.enumerated() {
                    let materialName = existingMaterial.name ?? "unnamed_\(index)"
                    print("   Processing material [\(index)]: \(materialName)")
                    
                    // Try to match material by name and apply JSON colors
                    if let materialData = json[materialName] as? [String: Any],
                       let stages = materialData["Stages"] as? [[String: Any]],
                       let firstStage = stages.first,
                       let baseColorArray = firstStage["baseColorFactor"] as? [Double] {
                        
                        let material = SCNMaterial()
                        material.name = materialName
                        material.lightingModel = .physicallyBased
                        
                        // Apply base color
                        material.diffuse.contents = UIColor(
                            red: CGFloat(baseColorArray[0]),
                            green: CGFloat(baseColorArray[1]),
                            blue: CGFloat(baseColorArray[2]),
                            alpha: CGFloat(baseColorArray[3])
                        )
                        
                        // Apply metallic and roughness
                        if let metallic = firstStage["metallicFactor"] as? Double {
                            material.metalness.contents = metallic
                        }
                        
                        if let roughness = firstStage["roughnessFactor"] as? Double {
                            material.roughness.contents = roughness
                        }
                        
                        // CRITICAL: Enable double-sided rendering
                        material.isDoubleSided = true
                        
                        geometry.materials[index] = material
                        
                        print("   ✅ Applied \(materialName): RGB(\(baseColorArray[0]), \(baseColorArray[1]), \(baseColorArray[2]))")
                    } else {
                        // Even if no JSON match, ensure double-sided
                        existingMaterial.isDoubleSided = true
                        print("   ⚠️ No JSON match for '\(materialName)', using existing (set double-sided)")
                    }
                }
            }
        }
        
        print("🎨 Material application complete!")
    }
    
    private func addAccentLights(to scene: SCNScene) {
        // Green accent light (left)
        let greenLight = SCNNode()
        greenLight.light = SCNLight()
        greenLight.light?.type = .omni
        greenLight.light?.color = UIColor(red: 0.0, green: 0.735, blue: 0.007, alpha: 1.0)
        greenLight.light?.intensity = 300
        greenLight.position = SCNVector3(-5, 2, 5)
        scene.rootNode.addChildNode(greenLight)
        
        // Yellow accent light (right)
        let yellowLight = SCNNode()
        yellowLight.light = SCNLight()
        yellowLight.light?.type = .omni
        yellowLight.light?.color = UIColor(red: 0.704, green: 0.735, blue: 0.002, alpha: 1.0)
        yellowLight.light?.intensity = 300
        yellowLight.position = SCNVector3(5, -2, 5)
        scene.rootNode.addChildNode(yellowLight)
        
        // Pink accent light (back)
        let pinkLight = SCNNode()
        pinkLight.light = SCNLight()
        pinkLight.light?.type = .omni
        pinkLight.light?.color = UIColor(red: 0.735, green: 0.024, blue: 0.549, alpha: 1.0)
        pinkLight.light?.intensity = 200
        pinkLight.position = SCNVector3(0, 3, -3)
        scene.rootNode.addChildNode(pinkLight)
    }
    
    private func createFallbackDNA() -> SCNNode {
        // Create a simple double helix structure as fallback
        let helixNode = SCNNode()
        
        let strand1 = SCNNode()
        let strand2 = SCNNode()
        
        // Create cylinders representing DNA strands
        for i in 0..<20 {
            let angle = Float(i) * 0.4
            let y = Float(i) * 0.2 - 2.0
            
            // Strand 1
            let sphere1 = SCNSphere(radius: 0.1)
            sphere1.firstMaterial?.diffuse.contents = UIColor.green
            let node1 = SCNNode(geometry: sphere1)
            node1.position = SCNVector3(cos(angle) * 0.5, y, sin(angle) * 0.5)
            strand1.addChildNode(node1)
            
            // Strand 2
            let sphere2 = SCNSphere(radius: 0.1)
            sphere2.firstMaterial?.diffuse.contents = UIColor.yellow
            let node2 = SCNNode(geometry: sphere2)
            node2.position = SCNVector3(cos(angle + .pi) * 0.5, y, sin(angle + .pi) * 0.5)
            strand2.addChildNode(node2)
        }
        
        helixNode.addChildNode(strand1)
        helixNode.addChildNode(strand2)
        
        // Add rotation
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotation.duration = 4.0
        rotation.repeatCount = .infinity
        helixNode.addAnimation(rotation, forKey: "rotation")
        
        // Tilt it
        helixNode.eulerAngles = SCNVector3(Float.pi / 6, Float.pi / 4, 0)
        
        return helixNode
    }
}

#Preview("iPhone 17 Pro Simulation") {
    DNALoadingView(isLoadingComplete: .constant(false))
}
