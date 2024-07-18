//
//  ChatDialog.swift
//  Licenta
//
//  Created by Georgiana Costea on 20.03.2024.
//

import SwiftUI

struct ChatDialog: Shape {
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 13, height: 13))
        return Path(path.cgPath)
    }
}



