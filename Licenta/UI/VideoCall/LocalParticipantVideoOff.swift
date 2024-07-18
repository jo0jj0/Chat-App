//
//  LocalParticipanteVideoOff.swift
//  Licenta
//
//  Created by Georgiana Costea on 18.06.2024.
//

import SwiftUI

struct LocalParticipantVideoOff: View {
  let profilePicture: String
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: profilePicture)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .clipped()
                        .padding()
                case .empty:
                    ProgressView()
                        .frame(width: 140, height: 180)
                        .padding()
                default:
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .clipped()
                        .padding()
                }
            }
            .frame(width: 140, height: 180)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding()
            .blur(radius: 6.0)
            
            AsyncImage(url: URL(string: profilePicture)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .frame(width: 150, height: 150)
                        .shadow(color: .primary, radius: 5)
                       
                case .empty:
                    ProgressView()
                        .frame(width: 150, height: 150)
                        .padding()
                default:
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .clipped()
                        .padding()
                }
            }
        }
        .overlay() {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.black.opacity(0.5), lineWidth: 4)
                .frame(width: 140, height: 180)
        }
    }
}

struct LocalParticipantVideoOff_Previews: PreviewProvider {
    @State static var profilePicture = "https://th.bing.com/th/id/R.bdf7ba9a5d361bc463e70e6ee8f7a1da?rik=FIlX39ntHMLKjg&riu=http%3a%2f%2froneradionowindy.files.wordpress.com%2f2017%2f11%2f15100028051007.jpg%3fquality%3d80%26strip%3dall%26strip%3dall&ehk=EO3jUZUXQStOI7ATday8O9dhgon%2blT%2f7RMz0IJA%2f1Bo%3d&risl=&pid=ImgRaw&r=0"

    static var previews: some View {
        LocalParticipantVideoOff(profilePicture: profilePicture)
    }
}
