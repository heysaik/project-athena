//
//  InsightBlock.swift
//  Athena
//
//  Created by Sai Kambampati on 5/30/22.
//

import SwiftUI

struct InsightBlock: View {
    var highlightString: String
    var descriptionString: String
    var size: CGFloat = 200
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundColor(.white.opacity(0.5))
                .frame(width: size, height: size, alignment: .center)
            VStack(alignment: .leading) {
                Text(highlightString)
                    .font(.custom("FoundersGrotesk-Bold", size: 45))
                Spacer()
                Text(descriptionString)
                    .titleTwo()
            }
            .padding()
            .foregroundColor(.white)
        }
    }
}
