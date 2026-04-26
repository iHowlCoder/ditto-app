//
//  DNALoadingPreview.swift
//  ditto-hacks
//
//  Preview of the actual loading screen experience
//

import SwiftUI
import Combine

struct DNALoadingPreview: View {
    @State private var isLoadingComplete = false
    @State private var timeRemaining: Double = 10.0
    @State private var showDebugInfo = false
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            if !isLoadingComplete {
                DNALoadingView(isLoadingComplete: $isLoadingComplete)
                    .overlay(alignment: .topTrailing) {
                        VStack(alignment: .trailing, spacing: 5) {
                            // Debug timer display
                            Text(String(format: "%.1fs", timeRemaining))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            
                            if showDebugInfo {
                                Text("Camera: (-16, 10, 40)")
                                    .font(.caption2)
                                    .foregroundColor(.green.opacity(0.5))
                                
                                Text("FOV: 60°")
                                    .font(.caption2)
                                    .foregroundColor(.green.opacity(0.5))
                                
                                Text("Scale: 0.93x")
                                    .font(.caption2)
                                    .foregroundColor(.yellow.opacity(0.5))
                                
                                Text("Rotation: (7°, 18°, -18°)")
                                    .font(.caption2)
                                    .foregroundColor(.yellow.opacity(0.5))
                                
                                Text("Baked Animation")
                                    .font(.caption2)
                                    .foregroundColor(.green.opacity(0.5))
                            }
                        }
                        .padding()
                    }
                    .overlay(alignment: .topLeading) {
                        Button(showDebugInfo ? "Hide Info" : "Show Info") {
                            showDebugInfo.toggle()
                        }
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.3))
                        .padding()
                    }
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 0.1
                        }
                    }
            } else {
                VStack(spacing: 20) {
                    Text("Loading Complete!")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("10 seconds elapsed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("DNA model fills entire screen - no UI elements ✓")
                        .font(.caption)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Reset") {
                        isLoadingComplete = false
                        timeRemaining = 10.0
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    DNALoadingPreview()
}
