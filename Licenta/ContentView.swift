//
//  ContentView.swift
//  Licenta
//
//  Created by Georgiana Costea on 13.03.2024.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @AppStorage("log_status") private var logStatus: Bool = false
    
    var body: some View {
        if logStatus {
            HomeView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
