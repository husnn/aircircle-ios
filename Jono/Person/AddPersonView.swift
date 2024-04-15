//
//  AddPersonView.swift
//  Jono
//
//  Created by Husnain on 29/02/2024.
//

import Contacts
import SwiftUI

struct AddPersonView: View {
    @Environment(\.dismiss) var dismiss
    
    let initialName: String?
    
    init(name: String? = nil) {
       initialName = name
    }
    
    private let avatarSize: CGFloat = 100.0;
    
    @State private var name: String = "";
    @State private var bio: String = "";
    @FocusState private var isBioFocused: Bool;
    
    @State private var contact: CNContact? = nil
    @State private var showContactPicker: Bool = false
    
    @StateObject var vm = AddPersonViewModel()
    
    var body: some View {
        VStack {
            HStack() {
                Spacer()
                
                Button(action: {
                    if vm.create(name: name, bio: bio) {
                        dismiss()
                    }
                }, label: {
                    Text("Save")
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .font(.system(size: 16, weight: .regular))
                        .background(Color.gray.opacity(0.1))
                        .foregroundStyle(Color.jonoBlack)
                        .clipShape(Capsule())
                })
                .disabled(name.isEmpty)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                Spacer()
                    .frame(height: 30)
                
                VStack(alignment: .center, spacing: 30) {
                    VStack(alignment: .center, spacing: 20) {
                        Circle()
                            .fill(Color.jonoOlive)
                            .frame(width: avatarSize, height: avatarSize)
                            .overlay {
                                Text(name.initials())
                            }
                        
                        TextField("Full Name", text: $name, axis: .horizontal)
                            .textContentType(.name)
                            .textInputAutocapitalization(.words)
                            .font(.title())
                            .frame(maxWidth: 300)
                            .fixedSize()
                            .multilineTextAlignment(.center)
                            .onSubmit {
                                if bio.isEmpty { isBioFocused = true }
                            }
                    } 
                    
                    TextField("Add a short bio", text: $bio, axis: .vertical)
                        .font(.body())
                        .multilineTextAlignment(.center)
                        .focused($isBioFocused)
                        .submitLabel(.done)
                        .onChange(of: bio) { newValue in
                            if let last = newValue.last, last == "\n" {
                                bio.removeLast()
                                isBioFocused = false
                            }
                        }
                    
                    SecondaryButton(text: "Import from Contacts", icon: UIImage(named: "ic_contacts"), onTap: {
                        showContactPicker = true
                    })
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .sheet(isPresented: $showContactPicker) {
            ContactPicker(contact: $contact)
        }
        .onAppear {
            if let initial = initialName {
                name = initial
            }
        }
        .onChange(of: contact) { val in
            guard let contact = val else { return }
            name = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
            isBioFocused = true
        }
    }
}

#Preview {
    AddPersonView()
}
