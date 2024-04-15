//
//  InferenceView.swift
//  Jono
//
//  Created by Husnain on 15/03/2024.
//

import SwiftUI

struct SuggestedNoteView: View {
    let data: SuggestedNote
    
    var body: some View {
        VStack(alignment: .leading) {
            if let person = data.person {
                HStack {
                    PersonAvatarView(name: person.name, avatar: person.avatar, isSmall: true)
                        .frame(width: 30, height: 30)
                    Text(person.name)
                        .font(.label())
                }
                .padding(.bottom, 10)
            }
            HStack {
                Text(data.note.text)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
    }
}

struct SuggestedNote: Identifiable {
    let id = UUID()
    var person: Person?
    var note: Note
}

struct InferenceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var contextService: ContextService
    
    let audioPath: String
    
    @StateObject private var vm = InferenceViewModel()
    
    @State private var selected: SuggestedNote? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let note = selected {
                CreateNoteView(
                    person: note.person,
                    text: note.note.text,
                    onCreate: { note in
                        contextService.createNote(note)
                        
                        if let selected = selected, let index = vm.notes.firstIndex(where: { item in item.note.id == selected.note.id }) {
                            vm.notes.remove(at: index)
                        }
                        
                        selected = nil
                        
                        if vm.notes.isEmpty {
                            dismiss()
                        }
                    }, onBack: {
                        selected = nil
                    })
            } else {
                HStack(alignment: .bottom) {
                    Text("Notes")
                        .font(.largeTitle())
                    
                    Spacer()
                    
                    Button("Discard", action: {
                        dismiss()
                    })
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                
                if vm.isFetching {
                    ZStack(alignment: .center) {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                ScrollView(.vertical) {
                    ForEach(vm.notes, id: \.id) { data in
                        SuggestedNoteView(data: data)
                            .padding(.horizontal, 20)
                            .padding(.top, 5)
                            .onTapGesture {
                                selected = data
                            }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            vm.setup(contextService: contextService)
            
            Task {
                await vm.fetchResult(audioPath: audioPath)
            }
        }
    }
}

#Preview {
    ZStack {
        SuggestedNoteView(data: SuggestedNote(
            person: .init(name: "John Doe"),
            note: .init(personId: 1, text: "This is a test note")
        ))
    }
}
