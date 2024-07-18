//
//  SheetPhotoBig.swift
//  Licenta
//
//  Created by Georgiana Costea on 20.06.2024.
//

import SwiftUI

struct SheetPhotoBig: View {
    let url: String
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .empty:
                    ProgressView().frame(width: 300, height: 300)
                default:
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                }
            }
        }
        .navigationTitle("Imagine Mare")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SheetPhotoBig(url: "https://i0.wp.com/picjumbo.com/wp-content/uploads/camping-on-top-of-the-mountain-during-sunset-free-photo.jpg?w=600&quality=80")
}
