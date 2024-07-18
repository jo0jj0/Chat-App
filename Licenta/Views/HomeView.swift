//
//  MainView.swift
//  Licenta
//
//  Created by Georgiana Costea on 26.03.2024.
//

import SwiftUI

struct PreviewEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}


struct HomeView: View {
    @ObservedObject private var viewModel = HomeViewModel()
    @Environment(\.isPreview) private var isPreview
    @AppStorage("log_status") var logStatus: Bool = false
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack{
            TabView(selection: $viewModel.currentTab) {
                if viewModel.currentTab == .home {
                    if isPreview {
                        ChatListView(showTabBar: $viewModel.showTabBar)
                        .tabItem { Text("1") }
                        .tag(1)
                    } else {
                        ZStack {
                                ChatListView(showTabBar: $viewModel.showTabBar)
                                    .tabItem { Text("1") }
                                    .tag(1)
                        }
                     
                    }
                } else if viewModel.currentTab == .calls {
                    CallsListView(showTabBar: $viewModel.showTabBar)
                        .tabItem { Text("2") }
                        .tag(2)
                    
                } else if viewModel.currentTab == .contacts {
                    if isPreview {
                        ContactsView(showTabBar: $viewModel.showTabBar)
                            .tabItem { Text("3") }
                            .tag(3)
                    } else {
                        ZStack {
                            ContactsView(showTabBar: $viewModel.showTabBar)
                                .tabItem { Text("3") }
                                .tag(3)
                        }
                    }
                }
                else if viewModel.currentTab == .profile {
                    if isPreview {
                        ProfileView(showTabBar: $viewModel.showTabBar)
                            .tabItem { Text("4") }
                            .tag(4)
                    } else {
                        ZStack{
                                ProfileView(showTabBar: $viewModel.showTabBar)
                                    .tabItem { Text("4") }
                                    .tag(4)
                        }
                    }
                }
            }
            if viewModel.showTabBar{
                CustomTabBar(currentTab: $viewModel.currentTab, showTabBar: $viewModel.showTabBar)
            }
        }
        .ignoresSafeArea()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        return HomeView()
            .environment(\.isPreview, true)
    }
}
