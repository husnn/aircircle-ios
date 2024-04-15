//
//  SearchView.swift
//  Jono
//
//  Created by Husnain on 08/03/2024.
//

import SwiftUI

struct SearchBoxView: View {
    @Binding var text: String
    
    let isRecording: Bool;
    let focusable: Bool;
    
    @FocusState private var isFocused: Bool;
    
    var body: some View {
        VStack() {
            HStack(alignment: .center, spacing: 15) {
                Image(uiImage: UIImage(named: "ic_command")!)
                    .resizable()
                    .frame(width: 12, height: 12*1.25)
                    .scaledToFit()
                    .opacity(isRecording ? 0.3 : 1)
                
                TextField(isRecording ? "Listening..." : "Search people and notes", text: $text)
                    .keyboardType(.default)
                    .font(.body())
                    .lineLimit(1)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .disabled(!focusable)
                
                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .onAppear {
            isFocused = focusable
        }
    }
}

struct PersonResultRow: View {
    let person: Person
    let create: Bool
    
    let avatarSize: CGFloat = 50.0
    
    var body: some View {
        HStack(spacing: 20) {
            if !create {
                PersonAvatarView(name: person.name, avatar: person.avatar)
                    .frame(width: avatarSize, height: avatarSize)
            } else {
                Circle()
                    .fill(Color.jonoOlive)
                    .overlay {
                        Image(systemName: "plus")
                    }
                    .frame(width: avatarSize, height: avatarSize)
            }
            
            Text(person.name)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

struct SearchResults: View {
    @Binding var persons: [Person]
    let term: String
    let onSelect: (_ person: Person) -> Void
    let onCreateNew: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if !term.isEmpty {
                Text("PEOPLE")
                    .font(.system(size: 12, weight: .semibold))
                    .opacity(0.5)
                
                VStack(spacing: 10) {
                    ForEach(persons, id: \.id) { person in
                        PersonResultRow(person: person, create: false)
                            .onTapGesture {
                                onSelect(person)
                            }
                    }
                    
                    PersonResultRow(person: Person(name: "Create '\(term.capitalized)'"), create: true)
                        .onTapGesture {
                            onCreateNew()
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

#Preview("SearchResults") {
    @State var persons: [Person] = [
        Person(id: 1, name: "Husnain Javed"),
        Person(id: 2, name: "Raduan Al-Shedivat"),
        Person(id: 3, name: "Najmuzzaman Mohammad")
    ]
    
    return SearchResults(persons: $persons, term: "Johnny Appleseed", onSelect: { _ in }, onCreateNew: {})
}

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var personService: PersonService
    
    let animation: Namespace.ID
    
    let onPersonSelect: (_ person: Person) -> Void
    let onCreateNew: (_ name: String) -> Void
    
    @FocusState private var searchFocused: Bool
    
    @StateObject private var vm = SearchViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            SearchBoxView(text: $vm.input, isRecording: false, focusable: true)
                .matchedGeometryEffect(id: "search_input", in: animation)
            
            Spacer()
            
            ScrollView(.vertical) {
                SearchResults(persons: $vm.persons, term: vm.input, onSelect: onPersonSelect, onCreateNew: {
                    onCreateNew(vm.input.capitalized)
                })
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            searchFocused = true
            vm.setup(personService: personService)
        }
    }
}

//#Preview {
//    @Namespace var searchAnimation
//    
//    return SearchView(animation: searchAnimation)
//}
