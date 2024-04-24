//
//  SearchView.swift
//  Aircircle
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
                    .fill(Color.aircircleOlive)
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

struct NoteResultRow: View {
    let note: NoteResult
    let searchTerm: String
    
    private var attributedString: AttributedString {
        var attributedString = AttributedString(note.note.text)

        if let range = attributedString.range(of: searchTerm, options: .caseInsensitive) {
            attributedString[range].backgroundColor = .yellow
        }

        return attributedString
    }
    
    var body: some View {
        let person = note.person
        
        VStack(alignment: .leading) {
            HStack {
                PersonAvatarView(name: person.name, avatar: person.avatar, isSmall: true)
                    .frame(width: 30, height: 30)
                Text(person.name)
                    .font(.label())
            }
            .padding(.bottom, 10)
                
            Text(attributedString)
                .font(.label())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 15)
        .padding(.bottom, 20)
        .padding(.horizontal, 20)
        .background(Color.aircircleLightGrey)
        .clipShape(
            RoundedRectangle(cornerRadius: 10)
        )
    }
}

struct SearchResults: View {
    @Binding var persons: [Person]
    @Binding var notes: [NoteResult]
    
    let term: String
    let onSelect: (_ person: Person, _ noteID: Int64?) -> Void
    let onCreateNew: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if !term.isEmpty {
                VStack(alignment: .leading, spacing: 20) {
                    Text("PEOPLE")
                        .font(.system(size: 12, weight: .semibold))
                        .opacity(0.5)
                    
                    VStack(spacing: 10) {
                        ForEach(persons, id: \.id) { person in
                            PersonResultRow(person: person, create: false)
                                .onTapGesture {
                                    onSelect(person, nil)
                                }
                        }
                        
                        PersonResultRow(person: Person(name: "Create '\(term.capitalized)'"), create: true)
                            .onTapGesture {
                                onCreateNew()
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if !notes.isEmpty {
                        Text("NOTES")
                            .font(.system(size: 12, weight: .semibold))
                            .opacity(0.5)
                    }
                }
                .padding(.horizontal, 20)
                
                VStack(spacing: 10) {
                    ForEach(notes, id: \.note.id) { note in
                        NoteResultRow(note: note, searchTerm: term)
                            .onTapGesture {
                                onSelect(note.person, note.note.id)
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("SearchResults") {
    @State var persons: [Person] = [
        Person(id: 1, name: "Husnain Javed"),
        Person(id: 2, name: "Raduan Al-Shedivat"),
        Person(id: 3, name: "Najmuzzaman Mohammad")
    ]
    
    @State var notes: [NoteResult] = [
        .init(
            note: .init(personId: 1, text: "This is a test note"),
            person: .init(id: 1, name: "Husnain Javed")
        )]
    
    return SearchResults(persons: $persons, notes: $notes, term: "Test", onSelect: { _, _ in }, onCreateNew: {})
}

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var personService: PersonService
    @EnvironmentObject private var contextService: ContextService
    
    let animation: Namespace.ID
    
    let onPersonSelect: (_ person: Person, _ noteID: Int64?) -> Void
    let onCreateNew: (_ name: String) -> Void
    
    @FocusState private var searchFocused: Bool
    
    @StateObject private var vm = SearchViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            SearchBoxView(text: $vm.input, isRecording: false, focusable: true)
                .matchedGeometryEffect(id: "search_input", in: animation)
            
            Spacer()
            
            ScrollView(.vertical) {
                SearchResults(persons: $vm.persons,
                              notes: $vm.notes,
                              term: vm.input,
                              onSelect: onPersonSelect,
                              onCreateNew: {
                    onCreateNew(vm.input.capitalized)
                })
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            searchFocused = true
            vm.setup(personService: personService, contextService: contextService)
        }
    }
}

//#Preview {
//    @Namespace var searchAnimation
//
//    return SearchView(animation: searchAnimation)
//}
