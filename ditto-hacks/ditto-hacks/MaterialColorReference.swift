//
//  MaterialColorReference.swift
//  ditto-hacks
//
//  Quick visual reference for DNA material colors
//

import SwiftUI

struct MaterialColorReference: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("DNA Material Colors")
                    .font(.title)
                    .bold()
                    .padding()
                
                Text("From main.materials.json")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Material.001 - Dark Gray
                ColorCard(
                    name: "Material.001",
                    description: "Dark Gray",
                    color: Color(red: 0.235, green: 0.235, blue: 0.235),
                    rgb: "(0.235, 0.235, 0.235)"
                )
                
                // Material.002 - Light Gray
                ColorCard(
                    name: "Material.002",
                    description: "Light Gray",
                    color: Color(red: 0.906, green: 0.906, blue: 0.906),
                    rgb: "(0.906, 0.906, 0.906)"
                )
                
                // Material.003 - Green
                ColorCard(
                    name: "Material.003",
                    description: "Green",
                    color: Color(red: 0.0, green: 0.735, blue: 0.007),
                    rgb: "(0.0, 0.735, 0.007)"
                )
                
                // Material.004 - Yellow
                ColorCard(
                    name: "Material.004",
                    description: "Yellow/Lime",
                    color: Color(red: 0.704, green: 0.735, blue: 0.002),
                    rgb: "(0.704, 0.735, 0.002)"
                )
                
                // Material.005 - Red
                ColorCard(
                    name: "Material.005",
                    description: "Red",
                    color: Color(red: 0.735, green: 0.0, blue: 0.064),
                    rgb: "(0.735, 0.0, 0.064)"
                )
                
                // Material.006 - Pink
                ColorCard(
                    name: "Material.006",
                    description: "Pink/Magenta",
                    color: Color(red: 0.735, green: 0.024, blue: 0.549),
                    rgb: "(0.735, 0.024, 0.549)"
                )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Common Properties")
                        .font(.headline)
                        .padding(.top)
                    
                    HStack {
                        Text("Metallic Factor:")
                        Spacer()
                        Text("0.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Roughness Factor:")
                        Spacer()
                        Text("0.5")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Opacity:")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Lighting Model:")
                        Spacer()
                        Text("Physically Based")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

struct ColorCard: View {
    let name: String
    let description: String
    let color: Color
    let rgb: String
    
    var body: some View {
        HStack(spacing: 15) {
            // Color swatch
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("RGB: \(rgb)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    MaterialColorReference()
}
