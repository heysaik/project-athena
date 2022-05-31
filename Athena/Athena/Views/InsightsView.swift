//
//  InsightsView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/30/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct InsightsView: View {
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    @State private var booksRead = [Book]()
    @State private var numberOfDaysUsingAthena = 0

    var body: some View {
        GeometryReader { geometry in
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    HStack {
                        InsightBlock(highlightString: "\(booksRead.count)", descriptionString: "books read", size: geometry.size.width / 2.2)
                        Spacer()
                        InsightBlock(highlightString: "\(booksRead.map { $0.pageCount }.reduce(0, +))", descriptionString: "pages perused", size: geometry.size.width / 2.2)
                    }
                    HStack {
                        InsightBlock(highlightString: "\(Set(self.booksRead.map { $0.categories }).count)", descriptionString: "categories explored", size: geometry.size.width / 2.2)
                        Spacer()
                        InsightBlock(highlightString: "\(numberOfDaysUsingAthena)", descriptionString: "days of using Athena", size: geometry.size.width / 2.2)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Insights")
        .onAppear {
            if let user = auth.currentUser {
                // Load User create date
                let creationDate = user.metadata.creationDate ?? Date()
                let numberOfDays = Calendar.current.dateComponents([.day], from: creationDate, to: Date())
                self.numberOfDaysUsingAthena = numberOfDays.day!
                
                // Load Already Read
                Task {
                    let arSnapshot = try await firestore
                        .collection("alreadyRead")
                        .whereField("readerID", isEqualTo: user.uid)
                        .getDocuments()
                    for doc in arSnapshot.documents {
                        do {
                            let book = try doc.data(as: Book.self)
                            self.booksRead.append(book)
                        } catch let convertError {
                            print("Conversion Error: \(convertError.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}
