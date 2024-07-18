//
//  HomeViewModel.swift
//  Licenta
//
//  Created by Georgiana Costea on 12.04.2024.
//

import Foundation
import SwiftUI

enum FetchingState<T> {
    case idle
    case loading
    case loaded(T)
    case error
}


@MainActor
final class HomeViewModel: ObservableObject {
    @Published var currentTab: Tab = .home
    @Published var showTabBar = true
}
