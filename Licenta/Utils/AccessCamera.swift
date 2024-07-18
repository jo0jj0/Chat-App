//
//  AccessCamera.swift
//  Licenta
//
//  Created by Georgiana Costea on 12.06.2024.
//

import PhotosUI
import SwiftUI

struct AccessCamera: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    var sendMessageWithImage: (Data) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: AccessCamera
    
    init(picker: AccessCamera) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        if let imageData = selectedImage.jpegData(compressionQuality: 1.0) {
            self.picker.sendMessageWithImage(imageData) 
        }
        self.picker.isPresented.wrappedValue.dismiss()
    }
}
