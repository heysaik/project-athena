//
//  TextPreviewView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/30/22.
//

import SwiftUI
import FirebaseFirestore

struct TextPreviewView: View {
    var text: String
    var previewTitle: String
    var contentType: TextContentType = .description
    var bookID: String? = nil
    
    var body: some View {
        NavigationLink {
            ZStack {
                LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    Text(text)
                        .body()
                        .multilineTextAlignment(.leading)
                        .padding()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationBarTitle(previewTitle)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    if bookID != nil {
                        Button {
                            Task {
                                let gen = UINotificationFeedbackGenerator()
                                do {
                                    try await Firestore.firestore()
                                        .collection("alreadyRead")
                                        .document(bookID!)
                                        .updateData(["userReview": ""])
                                    gen.notificationOccurred(.success)
                                } catch let addError {
                                    print(addError.localizedDescription)
                                    gen.notificationOccurred(.error)
                                }
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                })
            }
        } label: {
            Text(text)
                .body()
                .multilineTextAlignment(.leading)
                .foregroundColor(.white)
                .lineLimit(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.black.opacity(0.25))
                )
        }
    }
}
