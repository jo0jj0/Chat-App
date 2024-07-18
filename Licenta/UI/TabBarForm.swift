//
//  TabBarf.swift
//  Licenta
//
//  Created by Georgiana Costea on 16.03.2024.
//

import SwiftUI

 struct Parabolic: Shape {
    var size: CGSize
    var xAxis: CGFloat
    
    var animatableData: CGFloat {
        get { return xAxis }
        set { xAxis = newValue }
    }
    
     func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            
            let middle = xAxis
            
            path.move(to: CGPoint(x: middle - (size.width / 2), y: 0))
            
            let to1 = CGPoint(x: middle, y: size.height * 1.5)
            let control1 = CGPoint(x: middle - (size.width / 4), y: 0)
            let control2 = CGPoint(x: middle - (size.width / 4), y: size.height * 1.5)
            
            let to2 = CGPoint(x: middle + (size.width / 2), y: 0)
            let control3 = CGPoint(x: middle + (size.width / 4), y: size.height * 1.5)
            let control4 = CGPoint(x: middle + (size.width / 4), y: 0)
            
            path.addCurve(to: to1, control1: control1, control2: control2)
            path.addCurve(to: to2, control1: control3, control2: control4)
        }
    }
}

struct TabBarForm: View {
    @Binding private var currentTab: Tab 
    
    init(currentTab: Binding<Tab>) {
          self._currentTab = currentTab
      }
    
    var body: some View {
        
        ZStack {
            Color(.clear) .background(.ultraThinMaterial)
                .mask(
                    Parabolic(size: CGSize(width: 200, height: 40), xAxis: tabBarOffset(for: currentTab))
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  public  func tabBarOffset(for tab: Tab) -> CGFloat {
            switch tab {
            case .home:
                return 50
            case .calls:
                return 147
            case .contacts:
               return 248
            case .profile:
                return 340
            }
        }
}

#Preview {
    let stateCurrentTab = State<Tab>(initialValue: .home)
    return TabBarForm(currentTab: stateCurrentTab.projectedValue)
}
