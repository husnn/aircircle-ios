//
//  HomeView.swift
//  Aircircle
//
//  Created by Husnain on 27/02/2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var contextService: ContextService
    @EnvironmentObject private var personService: PersonService

    @State var showSearchSheet: Bool = false
    @State var showAddPersonSheet: Bool = false
    @State var showCreateNoteSheet: Bool = false
    
    @Namespace var searchAnimation
    @State var searchTerm: String = ""
    
    @State var newPersonName: String = ""
    
    @ObservedObject var vm = HomeViewModel()
    
    @State var personSelected: Person?
    @State var selectedNoteID: Int64?
    
    var body: some View {
        ZStack(alignment: .leading) {
            GridView(
                persons: vm.persons,
                isRecording: $vm.isRecording,
                recordingDuration: Int(vm.recordingDurationMs / 1000),
                onSelect: { personId in
                    print("Selected person with ID: \(personId)")
                    
                    if personId == -1 {
                        showAddPersonSheet = true
                    }
                    
                    guard let person = vm.persons.first(where: { p in
                        p.id == personId
                    }) else { return }
                    
                    print("Selected person with name: \(person.name)")
                    
                    self.personSelected = person
                })
            
            VStack(spacing: 15) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer()
                            .frame(width: 20)
                        
                        ActionLabel(text: "Add person", icon: UIImage(named: "ic_add_person")) {
                            showAddPersonSheet = true
                        }
                        
                        ActionLabel(text: "Speak", icon: UIImage(named: "ic_microphone"), iconSize: CGSize(width: 14, height: 18)) {
                            vm.isRecording = true
                        }
                        
                        ActionLabel(text: "Create note", icon: UIImage(named: "ic_add_meeting")) {
                            showCreateNoteSheet = true
                        }
                        
                        Spacer()
                            .frame(width: 20)
                    }
                }
                .offset(y: vm.isRecording ? 100 : 0)
                
                SearchBoxView(text: $searchTerm, isRecording: vm.isRecording, focusable: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .allowsHitTesting(!vm.isRecording)
                    .onTapGesture {
                        showSearchSheet = true
                    }
                    .matchedGeometryEffect(id: "search_input", in: searchAnimation, isSource: true)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .background(Color.aircircleYellow)
        .animation(.easeOut(duration: 0.2), value: vm.isRecording)
        .sheet(isPresented: $showSearchSheet) {
            SearchView(animation: searchAnimation, onPersonSelect: {
                showSearchSheet = false
                personSelected = $0
                selectedNoteID = $1
            }, onCreateNew: { name in
                showSearchSheet = false
                newPersonName = name
            })
        }
        .sheet(isPresented: $showAddPersonSheet) {
            AddPersonView(name: newPersonName)
                .ignoresSafeArea(.all)
                .presentationDetents([.fraction(0.6)])
                .onDisappear {
                    newPersonName = ""
                    vm.fetchPersons()
                }
        }
        .sheet(isPresented: $showCreateNoteSheet) {
            CreateNoteView(onCreate: { note in
                contextService.createNote(note)
                showCreateNoteSheet = false
            })
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $personSelected) { person in
            PersonView(person: person, onRefresh: { dismiss in
                if dismiss {
                    personSelected = nil
                }
                vm.fetchPersons()
            }, highlightedNoteID: $selectedNoteID)
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $vm.audioRecordingPath) { url in
            InferenceView(audioPath: url.value)
                .interactiveDismissDisabled()
        }
        .preferredColorScheme(.light)
        .onChange(of: newPersonName) { name in
            showAddPersonSheet = !name.isEmpty
        }
        .onAppear {
            vm.setup(contextService: contextService, personService: personService)
            vm.fetchPersons()
        }
    }
}

#Preview {
    HomeView()
}
