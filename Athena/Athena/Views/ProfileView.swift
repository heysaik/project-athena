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
import CollectionViewPagingLayout
 
struct ProfileView: View {
    @State private var email = Auth.auth().currentUser!.email
    @State private var user = Auth.auth().currentUser
    @State private var showLogoutAlert = false
    @State private var loggedOut = false
    @State private var showAlreadyRead = true // If its false then it shows the wishlist
    @State private var wishlistedBooks = [Book]()
    @State private var alreadyReadBooks = [Book]()
    @State private var selectedBookID: Book.ID? = nil
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
 
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                        .edgesIgnoringSafeArea(.all)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(email!)
                            .font(.system(size: 25, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                        ScrollView{
                            Button {
                                // Edit Name
                            } label: {
                                ZStack(alignment: .leading){
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(height: 35)
                                        .foregroundColor(.white.opacity(0.2))
                                    Text("Edit Name")
                                        .font(.system(size: 20, design: .rounded)).bold()
                                        .foregroundColor(.white)
                                        .frame(alignment: .leading)
                                        .padding(10)
                                }
                            }
                            NavigationLink {
                                // Edit Email
                                Change_Email()
                            } label: {
                                ZStack(alignment: .leading){
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(height: 35)
                                        .foregroundColor(.white.opacity(0.2))
                                    Text("Edit Email")
                                        .font(.system(size: 20, design: .rounded)).bold()
                                        .foregroundColor(.white)
                                        .frame(alignment: .leading)
                                        .padding(10)
                                }
                            }
                            Button {
                                // Change Password
                            } label: {
                                ZStack(alignment: .leading){
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(height: 35)
                                        .foregroundColor(.white.opacity(0.2))
                                    Text("Change Password")
                                        .font(.system(size: 20, design: .rounded)).bold()
                                        .foregroundColor(.white)
                                        .frame(alignment: .leading)
                                        .padding(10)
                                }
                            }
                            Button {
                                // Show Insights
                            } label: {
                                ZStack(alignment: .leading){
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(height: 35)
                                        .foregroundColor(.white.opacity(0.2))
                                    Text("Insights")
                                        .font(.system(size: 20, design: .rounded)).bold()
                                        .foregroundColor(.white)
                                        .frame(alignment: .leading)
                                        .padding(10)
                                }
                            }
                            Button {
                                // Push Notifications screen
                            } label: {
                                ZStack(alignment: .leading){
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(height: 35)
                                        .foregroundColor(.white.opacity(0.2))
                                    Text("Push Notifications")
                                        .font(.system(size: 20, design: .rounded)).bold()
                                        .foregroundColor(.white)
                                        .frame(alignment: .leading)
                                        .padding(10)
                                }
                            }
                            Button {
                                // Clear Cache
                                SDImageCache.shared.clear(with: .all)
                            } label: {
                                ZStack(alignment: .leading){
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(height: 35)
                                        .foregroundColor(.white.opacity(0.2))
                                    Text("Clear Cache")
                                        .font(.system(size: 20, design: .rounded)).bold()
                                        .foregroundColor(.white)
                                        .frame(alignment: .leading)
                                        .padding(10)
                                }
                            }
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
                                                .font(.system(size: 18, design: .rounded))
                                                .foregroundColor(.black)
                                        }
                                    } else {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(height: 27)
                                                .foregroundColor(.white.opacity(0))
                                            Text("Already Read")
                                                .font(.system(size: 18, design: .rounded))
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
                                                .font(.system(size: 18, design: .rounded))
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        VStack {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(height: 27)
                                                    .foregroundColor(.white.opacity(1))
                                                Text("Wishlist")
                                                    .font(.system(size: 18, design: .rounded))
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
                                            .font(.system(size: 19, weight: .semibold, design: .default))
                                            .multilineTextAlignment(.center)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    Spacer()
                                } else {
                                    VStack(alignment: .center, spacing: 24) {
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
                                                            .frame(width: geometry.size.width * 0.6)
                                                            .cornerRadius(5, corners: [.topLeft, .bottomLeft])
                                                            .cornerRadius(13, corners: [.bottomRight, .topRight])
                                                        Text(book.title)
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 20, weight: .semibold, design: .default))
                                                        // Tried to implement a loop below to go through all of the authors but it kept timing out or giving errors. So im just showing the first author for now
                                                        Text(book.authors[0])
                                                            .font(.system(size: 16, weight: .light, design: .default))
                                                            .foregroundColor(.white)
//                                                        for author in (book.authors){
//                                                            Text(author)
//                                                                .font(.system(size: 16, weight: .light, design: .default))
//                                                                .foregroundColor(.white)
//                                                        }
//                                                      TODO: We can add this when we get to ratings
//                                                      ForEach(0..<5) { i in
//                                                          Image(systemName: "star.fill")
//                                                              .font(.system(size: 16))
//                                                              .foregroundColor(.yellow)
//                                                      }
                                                    }
 
                                                }
                                                .aspectRatio(0.66, contentMode: .fit)
                                                .frame(width: geometry.size.width * 0.7)
                                            }
                                        }
                                    }
                                    .padding()
                                }
                            } else { // // If the user is clicked on "already read"
                                if alreadyReadBooks.count == 0 {
                                    Spacer()
                                    VStack(spacing: 16) {
                                        Image(systemName: "book.closed")
                                        Text("You have not read any books yet.")
                                            .font(.system(size: 19, weight: .semibold, design: .default))
                                            .multilineTextAlignment(.center)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    Spacer()
                                } else {
                                    VStack(alignment: .center, spacing: 24) {
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
                                                            .frame(width: geometry.size.width * 0.6)
                                                            .cornerRadius(5, corners: [.topLeft, .bottomLeft])
                                                            .cornerRadius(13, corners: [.bottomRight, .topRight])
                                                        Text(book.title)
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 20, weight: .semibold, design: .default))
                                                        // Tried to implement a loop below to go through all of the authors but it kept timing out or giving errors. So im just showing the first author for now
                                                        Text(book.authors[0])
                                                            .font(.system(size: 16, weight: .light, design: .default))
                                                            .foregroundColor(.white)
//                                                        for author in (book.authors){
//                                                            Text(author)
//                                                                .font(.system(size: 16, weight: .light, design: .default))
//                                                                .foregroundColor(.white)
//                                                        }
//                                                      TODO: We can add this when we get to ratings
//                                                      ForEach(0..<5) { i in
//                                                          Image(systemName: "star.fill")
//                                                              .font(.system(size: 16))
//                                                              .foregroundColor(.yellow)
//                                                      }
                                                    }
 
                                                }
                                                .aspectRatio(0.66, contentMode: .fit)
                                                .frame(width: geometry.size.width * 0.7)
                                            }
                                        }
                                    }
                                    .padding()
                                }
                            }
                            HStack{
                                Spacer()
                                Button {
                                    // Log out of proifle
                                    showLogoutAlert = true
                                } label: {
                                    ZStack(alignment: .center){
                                        RoundedRectangle(cornerRadius: 50)
                                            .frame(width: 160, height: 40)
                                            .foregroundColor(.white.opacity(0.3))
                                        Text("Log Out")
                                            .font(.system(size: 20, design: .rounded)).bold()
                                            .foregroundColor(.white)
                                    }
                                }
                                .alert("Are you sure you want to log out?", isPresented: $showLogoutAlert) {
                                    Button("Yes") {
                                        loggedOut = true
                                        do { try Auth.auth().signOut() }
                                        catch { print("already logged out") }
                                    }
                                    Button("No") { }
                                }

                                Spacer()
                            }
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.vertical)
                        }
                        
                    }
                    .padding(.horizontal)
                }
                .navigationTitle("Profile")
                .fullScreenCover(isPresented: $loggedOut) { // Shows OnboardingOne if the user logs out
                    OnboardingOne()
                }
                .tint(.white)
                .onAppear {
                    if let user = auth.currentUser {
                        firestore
                            .collection("users")
                            .document(user.uid)
                            .addSnapshotListener { docSnapshot, error in
                                guard error == nil else {
                                    print(error!.localizedDescription)
                                    return
                                }
                                
                                if let snapshot = docSnapshot {
                                    do {
                                        let userData = try snapshot.data(as: User.self)
                                        self.wishlistedBooks = userData.wishlist.sorted(by: {$0.title < $1.title})
                                        if self.wishlistedBooks.count > 0 {
                                            self.selectedBookID = wishlistedBooks.first!.id
                                        }
                                        self.alreadyReadBooks = userData.alreadyRead.sorted(by: {$0.title < $1.title})
                                        if self.alreadyReadBooks.count > 0 {
                                            self.selectedBookID = alreadyReadBooks.first!.id
                                        }
                                    } catch let convertError {
                                        print("Conversion Error: \(convertError.localizedDescription)")
                                    }
                                }
                            }
                    }
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

