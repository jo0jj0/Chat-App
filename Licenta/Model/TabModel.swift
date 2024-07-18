//
//  File.swift
//  Licenta
//
//  Created by Georgiana Costea on 13.03.2024.
//

import Foundation

enum Tab: String, CaseIterable {
    case home = "house"
    case calls = "phone"
    case contacts = "person.3"
    case profile = "person"
    
    var currentTab: Int {
        return Tab.allCases.firstIndex(of: self) ?? 0
    }
}
