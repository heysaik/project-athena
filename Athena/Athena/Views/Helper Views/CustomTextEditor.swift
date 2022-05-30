//
//  CustomTextEditor.swift
//  Athena
//
//  Created by Sai Kambampati on 5/29/22.
//

import SwiftUI

struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    init(placeholder: String, text: Binding<String>) {
        UITextView.appearance().backgroundColor = .clear
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.primary.opacity(0.25))
            }
            
            TextEditor(text: $text)
                .foregroundColor(.white)
        }
    }
}

