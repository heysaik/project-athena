//
//  ProfileView.swift
//  Athena
//
//  Created by Logan Thompson on 4/19/22.
//
 
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CollectionViewPagingLayout
import SDWebImageSwiftUI

struct ProfileView: View {
    @State private var user = Auth.auth().currentUser
    @State private var showAlreadyRead = true // If its false then it shows the wishlist
    @State private var wishlistedBooks = [Book]()
    @State private var alreadyReadBooks = [Book]()
    @State private var selectedBookID: Book.ID? = nil
    @State private var showSettingsView = false
    private var twoColumnGrid = [GridItem(.flexible(), alignment: .top), GridItem(.flexible(), alignment: .top)] // for already read and wishlist
  
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
                        }
                        ScrollView {
                            HStack(alignment: .top, spacing: 8) {
                                Button {
                                    // Already Read
                                    showAlreadyRead = true
                                } label: {
                                    if showAlreadyRead {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(height: 27)
                                                .foregroundColor(.white.opacity(1))
                                            Text("Already Read")
                                                .body()
                                                .foregroundColor(.black)
                                        }
                                    } else {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(height: 27)
                                                .foregroundColor(.white.opacity(0))
                                            Text("Already Read")
                                                .body()
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                Button {
                                    // Wishlist
                                    showAlreadyRead = false
                                } label: {
                                    if showAlreadyRead {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(height: 27)
                                                .foregroundColor(.white.opacity(0))
                                            Text("Wishlist")
                                                .body()
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        VStack {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(height: 27)
                                                    .foregroundColor(.white.opacity(1))
                                                Text("Wishlist")
                                                    .body()
                                                    .foregroundColor(.black)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                          
                            if !showAlreadyRead { // If the user is clicked on "wishlist"
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
                                    LazyVGrid(columns: twoColumnGrid) {
                                        ForEach (wishlistedBooks) { book in
                                            Button {
                                                // Open Album
                                            } label: {
                                                NavigationLink {
                                                    DetailView(book: book)
                                                } label: {
                                                    VStack{
                                                        WebImage(url: URL(string: book.imageLink))
                                                            .resizable()
                                                            .aspectRatio(0.66, contentMode: .fit)
                                                            .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                                                            .cornerRadius(5, corners: [.topLeft, .bottomLeft])
                                                            .cornerRadius(13, corners: [.bottomRight, .topRight])
                                                        Text(book.title)
                                                            .titleFour()
                                                            .foregroundColor(.white)
                                                            .fixedSize(horizontal: false, vertical: true) // some titles are long - do we always want it to show the full title?
                                                        // Tried to use "format" to format authors, but it would not work
                                                        ForEach (book.authors, id: \.self) { author in
//                                                            Text(author, format: .list(type: .and))
                                                            Text(author)
                                                                .caption()
                                                                .italic()
                                                                .foregroundColor(.white)
                                                        }
//                                                      TODO: We can add this when we get to ratings
//                                                      ForEach(0..<5) { i in
//                                                          Image(systemName: "star.fill")
//                                                              .font(.system(size: 16))
//                                                              .foregroundColor(.yellow)
//                                                      }
                                                    }
 
                                                }
                                                .aspectRatio(0.66, contentMode: .fit)
                                                .frame(width: geometry.size.width * 0.4)
                                            }
                                        }
                                    }
                                }
                            } else { // // If the user is clicked on "already read"
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
                                    LazyVGrid(columns: twoColumnGrid) {
                                        ForEach (alreadyReadBooks) { book in
                                            Button {
                                                // Open Album
                                            } label: {
                                                NavigationLink {
                                                    DetailView(book: book)
                                                } label: {
                                                    VStack{
                                                        WebImage(url: URL(string: book.imageLink))
                                                            .resizable()
                                                            .aspectRatio(0.66, contentMode: .fit)
                                                            .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                                                            .cornerRadius(5, corners: [.topLeft, .bottomLeft])
                                                            .cornerRadius(13, corners: [.bottomRight, .topRight])
                                                        Text(book.title)
                                                            .titleFour()
                                                            .foregroundColor(.white)
                                                            .fixedSize(horizontal: false, vertical: true) // some titles are long - do we always want it to show the full title?
                                                        // Tried to use "format" to format authors, but it would not work
                                                        ForEach (book.authors, id: \.self) { author in
//                                                            Text(author, format: .list(type: .and))
                                                            Text(author)
                                                                .caption()
                                                                .foregroundColor(.white)
                                                        }
    //                                                      TODO: We can add this when we get to ratings
    //                                                      ForEach(0..<5) { i in
    //                                                          Image(systemName: "star.fill")
    //                                                              .font(.system(size: 16))
    //                                                              .foregroundColor(.yellow)
    //                                                      }
                                                    }

                                                }
                                                .aspectRatio(0.66, contentMode: .fit)
                                                .frame(width: geometry.size.width * 0.4)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
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
                        
                        
//                        firestore
//                            .collection("users")
//                            .document(user.uid)
//                            .addSnapshotListener { docSnapshot, error in
//                                guard error == nil else {
//                                    print(error!.localizedDescription)
//                                    return
//                                }
//                                
//                                if let snapshot = docSnapshot {
//                                    do {
//                                        let userData = try snapshot.data(as: User.self)
//                                        self.wishlistedBooks = userData.wishlist.sorted(by: {$0.title < $1.title})
//                                        if self.wishlistedBooks.count > 0 {
//                                            self.selectedBookID = wishlistedBooks.first!.id
//                                        }
//                                        self.alreadyReadBooks = userData.alreadyRead.sorted(by: {$0.title < $1.title})
//                                        if self.alreadyReadBooks.count > 0 {
//                                            self.selectedBookID = alreadyReadBooks.first!.id
//                                        }
//                                    } catch let convertError {
//                                        print("Conversion Error: \(convertError.localizedDescription)")
//                                    }
//                                }
//                            }
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

