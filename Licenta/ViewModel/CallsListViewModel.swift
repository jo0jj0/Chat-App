//
//  CallsListViewModel.swift
//  Licenta
//
//  Created by Georgiana Costea on 27.04.2024.
//

import Foundation

@MainActor
final class CallsListViewModel: ObservableObject {
    
    @Published var currentTab: Tab = .home
    @Published var showLogoutDialog: Bool = false
}
