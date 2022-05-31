//
//  BookCoverView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/30/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct BookCoverView: View {
    var imageURLString: String
    var size: CGFloat = 157
    
    var body: some View {
        WebImage(url: URL(string: imageURLString.removeCurlFromPreview()))
            .resizable()
            .frame(width: size * 0.66, height: size, alignment: .center)
            .aspectRatio(contentMode: .fill)
            .cornerRadius(size * 0.019108280254777, corners: [.topLeft, .bottomLeft])
            .cornerRadius(size * 0.063694267515924, corners: [.bottomRight, .topRight])
            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}
