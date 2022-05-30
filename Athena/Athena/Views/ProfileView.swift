//
//  ProfileView.swift
//  Athena
//
//  Created by Logan Thompson on 4/19/22.
//
 
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI

struct ProfileView: View {
    @State private var user = Auth.auth().currentUser
    @State private var selectedSegment = "Already Read"
    @State private var wishlistedBooks = [Book]()
    @State private var alreadyReadBooks = [Book]()
    @State private var selectedBookID: Book.ID? = nil
    @State private var showSettingsView = false
    
    private var twoColumnGrid = [GridItem(.flexible(), alignment: .top), GridItem(.flexible(), alignment: .top)]
    private let segments = ["Already Read", "Wishlist"]
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
 
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                        .edgesIgnoringSafeArea(.all)
                    VStack(alignment: .leading, spacing: 8) {
                        if let user = auth.currentUser, let email = user.email {
                            Text(email)
                                .titleTwo()
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        ScrollView {
                            Picker("", selection: $selectedSegment) {
                                ForEach(segments, id:\.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                          
                            if selectedSegment == "Wishlist" {
                                // If the user is clicked on "wishlist"
                                if wishlistedBooks.count == 0 {
                                    Spacer()
                                    VStack(spacing: 16) {
                                        Image(systemName: "list.star")
                                        Text("You do not have any books on your wishlist.")
                                            .headline()
                                            .multilineTextAlignment(.center)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    Spacer()
                                } else {
                                    LazyVGrid(columns: twoColumnGrid, spacing: 30) {
                                        ForEach (wishlistedBooks) { book in
                                            NavigationLink {
                                                DetailView(book: book)
                                            } label: {
                                                BookCoverView(imageURLString: book.imageLink, size: geometry.size.width / 2)
                                            }
                                            .aspectRatio(0.66, contentMode: .fit)
                                            .frame(width: geometry.size.width / 2)
                                        }
                                    }
                                }
                            } else {
                                // If the user is clicked on "already read"
                                if alreadyReadBooks.count == 0 {
                                    Spacer()
                                    VStack(spacing: 16) {
                                        Image(systemName: "book.closed")
                                        Text("You have not read any books yet.")
                                            .headline()
                                            .multilineTextAlignment(.center)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    Spacer()
                                } else {
                                    LazyVGrid(columns: twoColumnGrid, spacing: 30) {
                                        ForEach (alreadyReadBooks) { book in
                                            NavigationLink {
                                                DetailView(book: book)
                                            } label: {
                                                BookCoverView(imageURLString: book.imageLink, size: geometry.size.width / 2)
                                            }
                                            .aspectRatio(0.66, contentMode: .fit)
                                            .frame(width: geometry.size.width / 2)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Profile")
                .tint(.white)
                .onAppear {
                    if let user = auth.currentUser {
                        // Load Wishlist
                        firestore
                            .collection("wishlist")
                            .whereField("readerID", isEqualTo: user.uid)
                            .addSnapshotListener { querySnapshot, error in
                                guard error == nil else {
                                    print(error!.localizedDescription)
                                    return
                                }
                                
                                if let snapshot = querySnapshot {
                                    let docs = snapshot.documents
                                    self.wishlistedBooks = []
                                    for doc in docs {
                                        do {
                                            let book = try doc.data(as: Book.self)
                                            self.wishlistedBooks.append(book)
                                        } catch let convertError {
                                            print("Conversion Error: \(convertError.localizedDescription)")
                                        }
                                    }
                                    
                                    self.wishlistedBooks.sort(by: {$0.title < $1.title})
                                }
                            }
                        
                        // Load Already Read
                        firestore
                            .collection("alreadyRead")
                            .whereField("readerID", isEqualTo: user.uid)
                            .addSnapshotListener { querySnapshot, error in
                                guard error == nil else {
                                    print(error!.localizedDescription)
                                    return
                                }
                                
                                if let snapshot = querySnapshot {
                                    let docs = snapshot.documents
                                    self.alreadyReadBooks = []
                                    for doc in docs {
                                        do {
                                            let book = try doc.data(as: Book.self)
                                            self.alreadyReadBooks.append(book)
                                        } catch let convertError {
                                            print("Conversion Error: \(convertError.localizedDescription)")
                                        }
                                    }
                                    
                                    self.alreadyReadBooks.sort(by: {$0.title < $1.title})
                                }
                            }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction, content: {
                        Button {
                            self.showSettingsView.toggle()
                        } label: {
                            Image(systemName: "gear")
                        }
                    })
                }
                .sheet(isPresented: $showSettingsView) {
                    SettingsView()
                }
            }
        }
    }
}
 
 
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

