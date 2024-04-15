//
//  GridView.swift
//  Jono
//
//  Created by Husnain on 27/02/2024.
//

import SwiftUI

struct PersonCircle: View {
    var item: PersonCircleItem
    
    var body: some View {
        AsyncImage(url: item.person?.avatar) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .background(Color.jonoOlive)
                    .clipShape(Circle())
            } else if phase.error != nil {
                // Missing/Error
            } else {
                // Loading
                if let person = item.person {
                    Circle()
                        .fill(Color.jonoOlive)
                        .overlay {
                            Text(person.name.initials())
                        }
                } else {
                    Image(uiImage: UIImage(named: item.fallbackImage)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .background(Color.jonoOlive)
                        .blur(radius: 5.0)
                        .opacity(0.5)
                        .clipShape(Circle())
                        .overlay {
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                                .opacity(0.4)
                        }
                }
            }
        }
    }
}

struct CircularLayout: View {
    let size: CGFloat
    let persons: [Person]
    let spacing: CGFloat
    @Binding var isRecording: Bool
    let recordingDuration: Int?
    let onSelect: (_ personId: Int64) -> Void
    
    let items: [PersonCircleItem]
    
    init(
        size: CGFloat,
        persons: [Person],
        fallbackItems: [PersonCircleItem],
        spacing: CGFloat = 100,
        isRecording: Binding<Bool>,
        recordingDuration: Int?,
        onSelect: @escaping (_ personId: Int64) -> Void
    ) {
        self.size = size
        self.persons = persons
        self.spacing = spacing
        self._isRecording = isRecording
        self.recordingDuration = recordingDuration
        self.onSelect = onSelect
        
        var items = fallbackItems
        
        for i in 0..<6 {
            if i < persons.count {
                items[i].person = persons[i]
            }
        }
        
        self.items = items
    }
    
    @State var outerRotatation: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let count = CGFloat(items.count)
            let circleSize: CGFloat = min(100, (width - spacing) / (count > 4 ? count / 2 : count))
            
            ZStack() {
                ZStack {
                    ForEach(items, id: \.id) { item in
                        let index = item.id - 1
                        let rotation = (CGFloat(index) / count) * 360.0
                        
                        PersonCircle(item: item)
                            .rotationEffect(.degrees(90))
                            .rotationEffect(.degrees(-rotation))
                            .rotationEffect(.degrees(-outerRotatation))
                            .frame(width: circleSize, height: circleSize)
                            .offset(x: (width - circleSize) / 2)
                            .rotationEffect(.degrees(-90))
                            .rotationEffect(.degrees(rotation))
                            .onTapGesture {
                                self.onSelect(item.person?.id! ?? -1)
                            }
                    }
                }
                .scaleEffect(isRecording ? 1.3 : 1)
                .opacity(isRecording ? 0.2 : 1)
                
                ZStack {
                    if !isRecording {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            .frame(width: 175, height: 175)
                    }
                    
                    
                    if isRecording {
                        Color.red
                            .opacity(0.05)
                            .clipShape(Circle())
                            .frame(width: 230, height: 230)
                            .transition(.scale.animation(.bouncy(duration: 0.15).delay(0.1)))
                        
                        Color.red
                            .opacity(0.1)
                            .clipShape(Circle())
                            .frame(width: 175, height: 175)
                            .transition(.scale.animation(.easeOut(duration: 0.10).delay(0.05)))
                    }
                    
                    Circle()
                        .strokeBorder(isRecording ? Color.red.opacity(0.7) : Color.jonoOlive, lineWidth: 4)
                    //                        .strokeBorder(Color.random(), lineWidth: 4)
                        .background(Circle().fill(isRecording ? Color.red.opacity(0.15) : Color.jonoGreen))
                        .frame(width: 130, height: 130)
                        .overlay {
                            if isRecording {
                                HStack {
                                    Image(systemName: "stop.fill")
                                        .foregroundStyle(Color.red)
                                    Text((recordingDuration ?? 0).secondsAsLength())
                                        .foregroundStyle(Color.red)
                                }
                            }
                        }
                        .rotationEffect(.degrees(-outerRotatation))
                }
                .onTapGesture {
                    isRecording.toggle()
                }
            }
            .frame(width: size, height: size)
            .background() {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    .frame(width: proxy.size.width - circleSize)
            }
            .rotationEffect(.degrees(outerRotatation))
            .onAppear() {
                withAnimation(.linear(duration: 20).speed(0.1).repeatForever(autoreverses: false)) {
                    outerRotatation = -360.0
                }
            }
        }
    }
}

struct PersonCircleItem {
    var id: Int64;
    var fallbackImage: String;
    var person: Person?;
}

let items = [
    PersonCircleItem(id: 1, fallbackImage: "face_7"),
    PersonCircleItem(id: 2, fallbackImage: "face_2"),
    PersonCircleItem(id: 3, fallbackImage: "face_3"),
    PersonCircleItem(id: 4, fallbackImage: "face_4"),
    PersonCircleItem(id: 5, fallbackImage: "face_5"),
    PersonCircleItem(id: 6, fallbackImage: "face_6"),
]

struct GridView: View {
    let persons: [Person]
    @Binding var isRecording: Bool
    let recordingDuration: Int?
    let onSelect: (_ personId: Int64) -> Void
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                CircularLayout(
                    size: proxy.size.width,
                    persons: persons,
                    fallbackItems: items,
                    isRecording: $isRecording,
                    recordingDuration: recordingDuration,
                    onSelect: onSelect
                )
                .frame(width: proxy.size.width)
                .offset(y: proxy.size.height / 5)
            }
            .background() {
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    .frame(width: proxy.size.width * 1.3)
            }
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
        .padding(.all, 15)
    }
}

#Preview {
    @State var isRecording: Bool = true;
    
    return GridView(persons: [
        Person(id: 1, name: "Husnain Javed"),
        Person(id: 2, name: "Raduan Al-Shedivat"),
        Person(id: 3, name: "Najmuzzaman Mohammad")
    ], isRecording: $isRecording, recordingDuration: nil) { personId in
        print("Selected: \(personId)")
    }
}
