//
//  MainBackground.swift
//  Licenta
//
//  Created by Georgiana Costea on 13.03.2024.
//

import SwiftUI

struct MainBackground: View {
    @State var animate: Bool = false
    
    struct CircleBackground: View { //nested struct
        @State var colorC: Color = Color("Circle1")
        var body: some View {
            Circle()
                .frame(width: 300, height: 300)
                .foregroundStyle(colorC)
            Circle()
                .frame(width: 150, height: 150)
                .foregroundStyle(colorC)
                .offset(x: 100, y: -290)
            Circle()
                .frame(width: 150, height: 150)
                .foregroundStyle(colorC)
                .offset(x: -100, y: 290)
        }
    }
    
    var body: some View {
        
        ZStack{
            CircleBackground(colorC: Color("Circle1").opacity(0.7))
                .blur(radius: animate ? 50 : 100)
                .offset(x: animate ? -50 : -130, y: animate ? -30 : -100)
                .task {
                    withAnimation(.easeInOut(duration: 5).repeatForever()) {
                        animate.toggle()
                    }
                }
            
            CircleBackground(colorC: Color("Circle2").opacity(0.7))
                .blur(radius: animate ? 50 : 100)
                .offset(x: animate ? 100 : 130, y: animate ? 150 : 100)
                .task {
                    withAnimation(.easeInOut(duration: 3).repeatForever()) {
                        animate.toggle()
                    }
                }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.babyBlue)
    }
}

#Preview {
    MainBackground()
}
