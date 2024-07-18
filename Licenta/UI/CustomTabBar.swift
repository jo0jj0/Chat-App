//
//  CustomTabBar.swift
//  Licenta
//
//  Created by Georgiana Costea on 16.03.2024.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var currentTab: Tab
    @Binding var showTabBar: Bool
    
    var body: some View {
        
        VStack{
            ZStack {
                
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: 95)
                
                ButtonTabBar()
                    .offset(x: buttonTabBarOffset(for: currentTab), y: -30)
                
                HStack(spacing: 0.0) {
                    ForEach(Tab.allCases, id: \.rawValue) { tab in
                        Button {
                            withAnimation(.easeInOut) {
                                currentTab = tab
                            }
                        } label: {
                            Image(systemName: tab.rawValue)
                                .frame(maxWidth: .infinity, alignment: .bottom)
                                .foregroundStyle(.primary)
                                .offset(y: currentTab == tab ? -30 : -10)
                        }
                    }
                }
            }
            .background(
                TabBarForm(currentTab: $currentTab))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        
    }
    
    func buttonTabBarOffset(for tab: Tab) -> CGFloat {
        switch tab {
        case .home:
            return -147
        case .calls:
            return -50
        case .contacts:
            return 52
        case .profile:
            return 147
            
        }
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        let currentTab = Binding.constant(Tab.home)
        let showTabBar = Binding.constant(true)
        return CustomTabBar(currentTab: currentTab, showTabBar: showTabBar)
    }
}
