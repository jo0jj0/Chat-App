//
//  Extensions.swift
//  Licenta
//
//  Created by Georgiana Costea on 20.04.2024.
//

import Foundation
import SwiftUI
import AVFoundation
import StreamVideo
import StreamChat


extension View {
    
    
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }
    
    @ViewBuilder
    func showLoading(_ status: Bool) -> some View {
        self
            .animation(.snappy) {content in
                content
                    .opacity(status ? 0 : 1)
            }
            .overlay {
                if status {
                    ZStack{
                        Capsule()
                            .fill(.bar)
                        ProgressView()
                    }
                }
            }
    }
    
    @ViewBuilder
    func customTextField(_ icon: String? = nil,  _ paddingTop: CGFloat = 0, _ paddingBottom: CGFloat = 0) -> some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            self
        }
        .padding(.leading, 15)
        .padding(.vertical, 12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 15)
        .padding(.top, paddingTop)
        .padding(.bottom, paddingBottom)
        .listRowInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
    }
}

extension EnvironmentValues {
    var isPreview: Bool {
        get { self[PreviewEnvironmentKey.self] }
        set { self[PreviewEnvironmentKey.self] = newValue }
    }
}

extension String {
    
    func removeWhiteSpace() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
//class ChatClient {
//    
//}

extension ChatClient {
    static var shared: ChatClient!
}

extension Date {
    
    func toString (format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string (from: self)
    }
}

extension TimeInterval {
    var formatElapsedTime: String {
        let minute = Int(self) / 60
        let second = Int(self) % 60
        return String(format: "%02d:%02d", minute, second)
    }
    
    static var stopTimeInterval: TimeInterval {
        return TimeInterval()
    }
    
    
}
