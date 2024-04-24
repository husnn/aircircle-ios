//
//  PersonView.swift
//  Aircircle
//
//  Created by Husnain on 29/02/2024.
//

import SwiftUI


struct PersonAvatarView: View {
    let name: String
    let avatar: URL?
    let fallbackImage: String?
    let isSmall: Bool
    
    init(name: String = "", avatar: URL?, fallbackImage: String? = nil, isSmall: Bool = false) {
        self.name = name
        self.avatar = avatar
        self.fallbackImage = fallbackImage
        self.isSmall = isSmall
    }
    
    var body: some View {
        AsyncImage(url: avatar) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .background(Color.aircircleOlive)
                    .clipShape(Circle())
            } else if phase.error != nil {
                // Missing/Error
            } else {
                // Loading
                if fallbackImage != nil {
                    Image(uiImage: UIImage(named: fallbackImage!)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .background(Color.aircircleOlive)
                        .blur(radius: 5.0)
                        .opacity(0.5)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.aircircleOlive)
                        .overlay {
                            Text(name.initials())
                                .font(isSmall ? .label() : .body())
                        }
                }
            }
        }
    }
}

struct NoteView: View {
    let note: Note
    let onDelete: (() -> Void)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Created \(note.createdAt.formatted(date: .long, time: .omitted))")
                .font(.label())
                .opacity(0.5)
            
            Text(note.text)
                .font(.label())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color.aircircleLightGrey)
        .contextMenu() {
            Button(action: onDelete, label: {
                Label("Delete", systemImage: "trash")
            })
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
}

struct PersonView: View {
    @EnvironmentObject var personService: PersonService
    @EnvironmentObject private var contextService: ContextService
    
    let person: Person;
    let onRefresh: ((_ dismiss: Bool) -> Void)?
    
    @Binding var highlightedNoteID: Int64?
    
    let avatarSize: CGFloat = 100.0
    
    @State private var showDeleteConfirmation: Bool = false
    
    @FocusState private var bioFocused: Bool
    @State private var bio: String = ""

    @State private var notes: [Note] = []
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Spacer()
                    .frame(height: 20)
                
                VStack(alignment: .center, spacing: 20) {
                    HStack {
                        Menu {
                            Button {
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            ZStack {
                                Image(systemName: "ellipsis")
                                    .rotationEffect(.degrees(90))
                                    .foregroundStyle(.gray)
                            }
                            .frame(width: 25, height: 25)
                            .clipShape(Rectangle())
                        }
                        .alert(isPresented: $showDeleteConfirmation) {
                            Alert(
                                title: Text("Are you sure?"),
                                message: Text("All data associated with this person will be deleted."),
                                primaryButton: .destructive(Text("Delete")) {
                                    if let id = person.id {
                                        let ok = personService.delete(id)
                                        showDeleteConfirmation = !ok
                                        onRefresh?(true)
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PersonAvatarView(name: person.name, avatar: person.avatar)
                        .frame(width: avatarSize, height: avatarSize)
                    
                    VStack(alignment: .center, spacing: 5) {
                        Text(person.name)
                            .font(.title())
                        Text("Since \(person.connectedAt.format(format: "MMMM yyyy"))")
                            .font(.label())
                            .opacity(0.6)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        TextField("Add a short bio", text: $bio, axis: .vertical)
                            .font(.body())
                            .multilineTextAlignment(.center)
                            .focused($bioFocused)
                            .submitLabel(.done)
                            .onChange(of: bio) { newValue in
                                if let last = newValue.last, last == "\n" {
                                    bio.removeLast()
                                    bioFocused = false
                                }
                            }
                            .onChange(of: bioFocused) { val in
                                if !val {
                                    _ = personService.setBio(personId: person.id!, text: bio)
                                    onRefresh?(false)
                                }
                            }
                            .onAppear {
                                bio = person.bio ?? ""
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 20)
                
                ForEach(notes, id: \.id) { note in
                    NoteView(note: note, onDelete: {
                        if let nid = note.id {
                            contextService.deleteNote(nid)
                        }
                        if let pid = person.id {
                            notes = contextService.getNotesForPerson(id: pid)
                        }
                    })
                    .opacity(
                        highlightedNoteID != nil
                            ? highlightedNoteID == note.id ? 1 : 0.2
                            : 1
                    )
                    
                }
                .padding(.top, 10)
                .onAppear() {
                    withAnimation(.easeInOut(duration: 2)) {
                        highlightedNoteID = nil
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            if let pid = person.id {
                notes = contextService.getNotesForPerson(id: pid)
            }
        }
    }
}

#Preview {
    let person = Person(name: "John")
    
    @State var highlightedNoteID: Int64? = nil
    
    return PersonView(person: person, onRefresh: nil, highlightedNoteID: $highlightedNoteID)
}
