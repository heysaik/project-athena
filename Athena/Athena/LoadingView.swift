//
//  LoadingView.swift
//  Athena
//
//  Created by Sai Kambampati on 4/17/22.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .foregroundColor(.black.opacity(0.25))
                .frame(width: 50, height: 50, alignment: .center)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .tint(.accentColor)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
