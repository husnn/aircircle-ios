//
//  CreateNoteView.swift
//  Jono
//
//  Created by Husnain on 11/03/2024.
//

import SwiftUI

struct CreateNoteView: View {
    @State private var person: Person?
    @State private var text: String
    let onCreate: ((_ note: Note) -> Void)
    let onBack: (() -> Void)?
    
    init(person: Person? = nil, text: String = "", onCreate: @escaping ((_ note: Note) -> Void), onBack: (() -> Void)? = nil) {
        self._person = State(initialValue: person)
        self._text = State(initialValue: text)
        self.onCreate = onCreate
        self.onBack = onBack
    }
    
    @FocusState private var isFocused: Bool
    
    @State private var selectPerson: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 30)
            
            if !selectPerson {
                VStack(alignment: .leading) {
                    HStack(alignment: .center, spacing: 15) {
                        if onBack != nil {
                            ZStack {
                                Image(systemName: "chevron.left")
                                    .imageScale(.medium)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onBack?()
                            }
                        }
                        
                        Text("Create note")
                            .font(.largeTitle())
                    }
                    
                    TextField("Start typing your notes about someone...", text: $text, axis: .vertical)
                        .lineLimit(2...)
                        .focused($isFocused)
                        .font(.system(size: 18, weight: .medium))
                        .padding(.vertical, 10)
                    
                    Button(action: {
                        selectPerson = true
                    }, label: {
                        if person == nil {
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .scaledToFit()
                        } else {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .scaledToFit()
                        }
                        
                        Text(person == nil ? "Assign to person" : "Assigned to \(person!.name)")
                    })
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .font(.body())
                    .background(Color.gray.opacity(0.1))
                    .foregroundStyle(Color.black)
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    Button("Save note") {
                        if let person = person {
                            onCreate(.init(personId: person.id ?? 0, text: text))
                        }
                    }
                    .buttonStyle(PrimaryButton())
                    .disabled(person == nil || text.isEmpty)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            } else {
                SelectPersonView(onSelect: {
                    person = $0
                    selectPerson = false
                }, onBack: {
                    selectPerson = false
                })
                .transition(.move(edge: .trailing))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .animation(.easeInOut(duration: 0.2), value: selectPerson)
    }
}

#Preview {
    CreateNoteView(person: nil, onCreate: { _ in })
}
