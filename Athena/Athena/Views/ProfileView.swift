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
    @State private var sortOption: SortOptions = .title

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
                                    VStack(spacing: 16) {
                                        Spacer()
                                        Image(systemName: "list.star")
                                        Text("You do not have any books on your wishlist.")
                                            .headline()
                                            .multilineTextAlignment(.center)
                                        Spacer()
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                } else {
                                    LazyVGrid(columns: twoColumnGrid, spacing: 30) {
                                        ForEach(rootViewModel.wishlistedBooks.sortBy(option: sortOption)) { book in
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
                                    VStack(spacing: 16) {
                                        Spacer()
                                        Image(systemName: "book.closed")
                                        Text("You have not read any books yet.")
                                            .headline()
                                            .multilineTextAlignment(.center)
                                        Spacer()
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                } else {
                                    LazyVGrid(columns: twoColumnGrid, spacing: 30) {
                                        ForEach(rootViewModel.alreadyReadBooks.sortBy(option: sortOption)) { book in
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
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        Menu(
                            content: {
                                Picker("", selection: $sortOption) {
                                    Text("Sort by Title")
                                        .tag(SortOptions.title)
                                    Text("Sort by Author")
                                        .tag(SortOptions.author)
                                }
                            },
                            label: {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        )
                    })
                    
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
        .navigationViewStyle(.stack)
    }
}
 
 
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

