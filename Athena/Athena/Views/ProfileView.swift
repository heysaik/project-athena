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
    @State private var selectedSegment: LibraryType = .alreadyRead
    @State private var showSettingsView = false
    @EnvironmentObject var rootViewModel: RootViewModel

    private var twoColumnGrid = [GridItem(.flexible(), alignment: .top), GridItem(.flexible(), alignment: .top)]
    private let segments: [LibraryType] = [.alreadyRead, .wishlist]
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
                                    Text($0.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                          
                            if selectedSegment == .wishlist {
                                // If the user clicked on "Wishlist"
                                if rootViewModel.wishlistedBooks.count == 0 {
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
                                        ForEach(rootViewModel.wishlistedBooks) { book in
                                            NavigationLink {
                                                DetailView(book: book)
                                                    .environmentObject(rootViewModel)
                                            } label: {
                                                BookCoverView(imageURLString: book.imageLink, size: geometry.size.width / 2)
                                            }
                                        }
                                    }
                                }
                            } else {
                                // If the user clicked on "Already Read"
                                if rootViewModel.alreadyReadBooks.count == 0 {
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
                                        ForEach(rootViewModel.alreadyReadBooks) { book in
                                            NavigationLink {
                                                DetailView(book: book)
                                                    .environmentObject(rootViewModel)
                                            } label: {
                                                BookCoverView(imageURLString: book.imageLink, size: geometry.size.width / 2)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Profile")
                .tint(.white)
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

