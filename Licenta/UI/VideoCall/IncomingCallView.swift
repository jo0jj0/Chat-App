//
//  IncomingCallView.swift
//  Licenta
//
//  Created by Georgiana Costea on 18.06.2024.
//

import SwiftUI

struct IncomingCallView: View {
    let profilePicture: String = "https://th.bing.com/th/id/R.bdf7ba9a5d361bc463e70e6ee8f7a1da?rik=FIlX39ntHMLKjg&riu=http%3a%2f%2froneradionowindy.files.wordpress.com%2f2017%2f11%2f15100028051007.jpg%3fquality%3d80%26strip%3dall%26strip%3dall&ehk=EO3jUZUXQStOI7ATday8O9dhgon%2blT%2f7RMz0IJA%2f1Bo%3d&risl=&pid=ImgRaw&r=0"
    @State private var isAnimating: Bool = false
    @State var isVideo: Bool = false
    var body: some View {
        ZStack {
            ZStack {
                AsyncImage(url: URL(string: profilePicture)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    case .empty:
                        ProgressView()
                    default:
                        Image(systemName: "person.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    }
                }
                .ignoresSafeArea()
            }
            .background(Color.gray.opacity(0.2))
            VStack {
                Text(isVideo ? "Incoming video call..." : "Incoming audio call...")
                    .font(.headline)
                Text("Joe Doe")
                    .font(.largeTitle).bold()
                Spacer()
                HStack(spacing: 150) {
                    Button {
                        
                    } label: {
                        Image(systemName: "phone.fill")
                            .font(.title)
                            .padding()
                            .background(Circle().tint(.green)
                                .scaleEffect(isAnimating ? 1.3 : 1.0)
                                .animation(
                                    Animation
                                        .easeInOut(duration: 0.7)
                                        .repeatForever(autoreverses: true),value: isAnimating)
                            )
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "phone.fill")
                            .font(.title)
                            .padding()
                            .background(Circle().tint(.red))
                    }
                }
                .padding()
            }
        }
        .onAppear(perform: {
            isAnimating = true
        })
    }
}

#Preview {
    IncomingCallView()
}
