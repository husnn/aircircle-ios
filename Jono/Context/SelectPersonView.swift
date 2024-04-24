//
//  SelectPersonView.swift
//  Jono
//
//  Created by Husnain on 11/03/2024.
//

import SwiftUI

struct PersonSearchBox: View {
    @Binding var text: String;
    @FocusState private var isFocused: Bool;
    
    var body: some View {
        VStack() {
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .scaledToFit()
                
                TextField("Type a name to search", text: $text)
                    .keyboardType(.default)
                    .font(.body())
                    .lineLimit(1)
                    .focused($isFocused)
                    .submitLabel(.done)
                
                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }
}

struct SelectPersonView: View {
    @EnvironmentObject private var personService: PersonService
    
    let onSelect: (_ person: Person) -> Void
    let onBack: (() -> Void)?

    @StateObject private var vm = SelectPersonViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 15) {
                ZStack {
                    Image(systemName: "chevron.left")
                        .imageScale(.medium)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onBack?()
                }
                
                Text("People")
                    .font(.largeTitle())
            }
            
            PersonSearchBox(text: $vm.input)
            
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(vm.persons, id: \.id) { person in
                    PersonResultRow(person: person, create: false)
                        .onTapGesture {
                            onSelect(person)
                        }
                }
                
                let name = vm.input
                
                if !name.isEmpty {
                    PersonResultRow(person: Person(name: "Create '\(name.capitalized)'"), create: true)
                        .onTapGesture {
                            if let person = personService.create(name: name.capitalized, bio: "") {
                                onSelect(person)
                            }
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .onAppear {
            vm.setup(personService: personService)
        }
    }
}

#Preview {
    SelectPersonView(onSelect: { _ in }, onBack: {})
        .environmentObject(PersonService())
}
