//
//  SwiftUIView.swift
//  Licenta
//
//  Created by Georgiana Costea on 18.03.2024.
//

import SwiftUI

struct ButtonTabBar: View {
    var body: some View {
        Circle()
            .fill( LinearGradient(
                stops: [
                    .init(color: .babyBlue, location: 0.05),
                    .init(color: .circle1, location: 0.95),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            )
            .frame(width: 70)
            .shadow(radius: 10)
    }
}

#Preview {
    ButtonTabBar()
}
