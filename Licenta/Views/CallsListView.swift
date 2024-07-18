//
//  ApplesView.swift
//  Licenta
//
//  Created by Georgiana Costea on 17.04.2024.
//

import SwiftUI
import Lottie
import Firebase

struct CallsListView: View {
    @ObservedObject private var viewModel = CallsListViewModel()
    @Binding var showTabBar: Bool
    @AppStorage("log_status") var logStatus: Bool = false
    @Environment(\.isPreview) private var isPreview
    @State var callList: [CallModel] = []
    
    let currentUid = UserManager.shared.getCurrentUserID()
    
    var body: some View {
        NavigationStack {
            ZStack {
                MainBackground()
                VStack {
                    Spacer()
                    ZStack(alignment: .topTrailing) {
                        if callList.isEmpty {
                            VStack(spacing: 0.0) {
                                GeometryReader { _ in
                                    if let bundle = Bundle.main.path(forResource: "ChatListAnimation", ofType: "json") {
                                        LottieView {
                                            await LottieAnimation.loadedFrom(url: URL(filePath: bundle))
                                        }
                                        .playing(loopMode: .loop)
                                    }
                                }
                                Text("No calls yet.")
                                    .padding()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .padding()
                        } else {
                            List {
                                ForEach(callList, id: \.id) { call in
                                    HStack(spacing: 0.0) {
                                        VStack(alignment: .leading) {
                                            AsyncImage(url: URL(string: call.profilePicture)) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .clipShape(Circle())
                                                        .frame(width: 90, height: 90)
                                                case .empty:
                                                    ProgressView()
                                                        .padding(33)
                                                default:
                                                    Image(systemName: "person.circle")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .padding()
                                                        .frame(width: 90, height: 90)
                                                }
                                            }
                                        }
                                        VStack(alignment: .leading, spacing: 5) {
                                            HStack {
                                                Text(call.userName)
                                                    .font(.title2.bold())
                                                Spacer()
                                                Text(formatDuration(seconds: call.duration))
                                                    .font(.callout.bold())
                                                    .foregroundStyle(.secondary)
                                            }
                                            HStack {
                                                if call.callerId == currentUid {
                                                    Image(systemName: "phone.arrow.up.right")
                                                } else {
                                                    Image(systemName: "phone.arrow.down.left")
                                                }
                                                Text(formatDate(timestamp: call.createdAt))
                                                    .font(.footnote)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        Spacer()
                                       
                                    }
                                    Divider()
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            .safeAreaPadding(.bottom, 80)
                            .listRowSpacing(-25.0)
                            .listStyle(.plain)
                            .background(.clear)
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
            }
            .navigationTitle("Calls")
            .onAppear {
                if isPreview {
                    callList = [
                        CallModel(id: "1",
                                  profilePicture: "https://th.bing.com/th/id/R.bdf7ba9a5d361bc463e70e6ee8f7a1da?rik=FIlX39ntHMLKjg&riu=http%3a%2f%2froneradionowindy.files.wordpress.com%2f2017%2f11%2f15100028051007.jpg%3fquality%3d80%26strip%3dall%26strip%3dall&ehk=EO3jUZUXQStOI7ATday8O9dhgon%2blT%2f7RMz0IJA%2f1Bo%3d&risl=&pid=ImgRaw&r=0",
                                  userName: "Joe",
                                  createdAt: Timestamp(date: Date()),
                                  duration: 10,
                                  callerId: "ss",
                                  receiverId: "String",
                                  callStarted: false),
                        CallModel(id: "2",
                                  profilePicture: "https://th.bing.com/th/id/R.bdf7ba9a5d361bc463e70e6ee8f7a1da?rik=FIlX39ntHMLKjg&riu=http%3a%2f%2froneradionowindy.files.wordpress.com%2f2017%2f11%2f15100028051007.jpg%3fquality%3d80%26strip%3dall%26strip%3dall&ehk=EO3jUZUXQStOI7ATday8O9dhgon%2blT%2f7RMz0IJA%2f1Bo%3d&risl=&pid=ImgRaw&r=0",
                                  userName: "Joe Doe",
                                  createdAt: Timestamp(date: Date()),
                                  duration: 35516,
                                  callerId: "ss",
                                  receiverId: "String",
                                  callStarted: false)
                    ]
                } else {
                    Task {
                        do {
                            callList = try await CallManager.shared.getAllCallsForCurrentUser()
                        } catch {
                            print("Failed to load calls: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    
    func formatDuration(seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds) s"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            
            let formattedString = String(format: "%02d:%02d", minutes, remainingSeconds)
            return formattedString
        }
    }
    
    func formatDate(timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}


struct CallsListView_Previews: PreviewProvider {
    static var previews: some View {
        CallsListView(showTabBar: .constant(true))
            .environment(\.isPreview, true)
    }
}
