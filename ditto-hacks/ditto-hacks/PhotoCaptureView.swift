//
//  PhotoCaptureView.swift
//  ditto-hacks
//
//  Camera and photo library picker for task verification
//

import SwiftUI
import PhotosUI

struct PhotoCaptureView: View {
    let category: String
    let task: String
    let onComplete: (UIImage) -> Void
    let onCancel: () -> Void
    
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Take a Photo")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Verify: \(task)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Preview or Camera Icon
                if let image = selectedImage {
                    // Show preview
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    
                    // Image size info
                    Text("Size: \(image.jpegSizeString(compressionQuality: 0.7))")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                } else {
                    // Camera icon
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    if selectedImage != nil {
                        // Submit button
                        Button(action: {
                            if let image = selectedImage {
                                print("📤 Submitting photo from PhotoCaptureView")
                                print("   Size: \(image.size)")
                                print("   Scale: \(image.scale)")
                                onComplete(image)
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                Text("Submit Photo")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.0, green: 0.9, blue: 0.4))
                            .cornerRadius(16)
                        }
                        
                        // Retake button
                        Button(action: {
                            selectedImage = nil
                        }) {
                            Text("Retake Photo")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0.0, green: 0.9, blue: 0.4), lineWidth: 1.5)
                                )
                        }
                    } else {
                        // Take Photo button (only show if camera is available)
                        if isCameraAvailable {
                            Button(action: {
                                sourceType = .camera
                                showImagePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 20))
                                    Text("Take Photo")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0.0, green: 0.9, blue: 0.4))
                                .cornerRadius(16)
                            }
                        } else {
                            // Show info message when camera not available
                            Text("📷 Camera not available on this device")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.vertical, 8)
                        }
                        
                        // Choose from Library button
                        Button(action: {
                            sourceType = .photoLibrary
                            showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 20))
                                Text("Choose from Library")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.0, green: 0.9, blue: 0.4), lineWidth: 1.5)
                            )
                        }
                    }
                    
                    // Cancel button
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: sourceType)
        }
        .confirmationDialog("Choose Photo Source", isPresented: $showActionSheet, titleVisibility: .visible) {
            if isCameraAvailable {
                Button {
                    print("📷 Camera selected")
                    sourceType = .camera
                    showImagePicker = true
                } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                }
            }
            
            Button {
                print("📚 Photo Library selected")
                sourceType = .photoLibrary
                showImagePicker = true
            } label: {
                Label("Choose from Library", systemImage: "photo.on.rectangle")
            }
            
            Button("Cancel", role: .cancel) {
                print("❌ Action sheet cancelled")
            }
        }
    }
}

// MARK: - UIImagePickerController Wrapper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.modalPresentationStyle = .fullScreen
        
        // Additional configuration for camera
        if sourceType == .camera {
            picker.cameraCaptureMode = .photo
            picker.showsCameraControls = true
        }
        
        print("🎬 ImagePicker created with source: \(sourceType == .camera ? "camera" : "photo library")")
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Force update presentation style if needed
        uiViewController.modalPresentationStyle = .fullScreen
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            print("📸 Image picker finished picking")
            print("Available keys: \(info.keys)")
            
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
                print("✅ Using edited image - Size: \(editedImage.size)")
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
                print("✅ Using original image - Size: \(originalImage.size)")
            } else {
                print("⚠️ No image found in picker result")
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("❌ Image picker cancelled")
            parent.dismiss()
        }
        
        // Additional delegate method for debugging
        func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
            print("🧭 Navigation will show: \(type(of: viewController))")
        }
    }
}

#Preview {
    PhotoCaptureView(
        category: "physique",
        task: "Complete 30 push-ups",
        onComplete: { _ in },
        onCancel: {}
    )
}
