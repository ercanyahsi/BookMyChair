//
//  ContactPicker.swift
//  BookMyChair
//
//  Created on 03/01/2026.
//

import SwiftUI
import ContactsUI

/// SwiftUI wrapper for CNContactPickerViewController
struct ContactPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onContactSelected: (String, String) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let contactPicker = CNContactPickerViewController()
            contactPicker.delegate = context.coordinator
            uiViewController.present(contactPicker, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPicker
        
        init(_ parent: ContactPicker) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            // Get name
            let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
            
            // Get phone number (prefer first mobile, then any phone)
            var phoneNumber = ""
            if let mobilePhone = contact.phoneNumbers.first(where: { $0.label == CNLabelPhoneNumberMobile })?.value.stringValue {
                phoneNumber = mobilePhone
            } else if let anyPhone = contact.phoneNumbers.first?.value.stringValue {
                phoneNumber = anyPhone
            }
            
            parent.onContactSelected(name, phoneNumber)
            parent.isPresented = false
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.isPresented = false
        }
    }
}
