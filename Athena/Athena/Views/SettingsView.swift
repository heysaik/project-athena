//
//  SettingsView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/7/22.
//

import SwiftUI
import SDWebImage
import FirebaseAuth
import FirebaseFirestore
import AlertKit

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    @State private var showPasswordAlert = false
    @State private var passwordChangedAlert = false
    @State private var clearCacheAlert = false
    @State private var showSearchClearedAlert = false
    @State private var loggedOut = false
    
    @State private var newName = ""
    @State private var newEmail = ""
    @State private var username = ""
    @State private var password = ""
    @StateObject var nameAlertManager = CustomAlertManager()
    @StateObject var emailAlertManager = CustomAlertManager()
    @StateObject var authAlertManager = CustomAlertManager()
    
    // Used to show the gradient
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                    .edgesIgnoringSafeArea(.all)
                Form {
                    Section(header: Label("About You", systemImage: "list.bullet.rectangle.fill").foregroundColor(.white).opacity(0.5)) {
                        HStack {
                            NavigationLink {
                                // Show Insights
                                InsightsView()
                            } label: {
                                Label("Insights", systemImage: "chart.xyaxis.line")
                                    .font(.custom("FoundersGrotesk-Regular", size: 17))
                                    .foregroundColor(.white)
                            }
                        }
                        HStack {
                            NavigationLink {
                                NotificationsView()
                            } label: {
                                Label("Push Notifications", systemImage: "bell.badge.fill")
                                    .font(.custom("FoundersGrotesk-Regular", size: 17))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .listItemTint(.white)
                    .listRowBackground(Color.white.opacity(0.2))
                    
                    Section(header: Label("Privacy and Security", systemImage: "lock.fill").foregroundColor(.white).opacity(0.5)) {
                        HStack {
                            Button {
                                // Edit Name
                                nameAlertManager.show()
                            } label: {
                                Label("Edit Name", systemImage: "person.fill")
                                    .font(.custom("FoundersGrotesk-Regular", size: 17))
                            }
                        }
                        HStack {
                            Button {
                                // Edit Email
                                authAlertManager.show()
                            } label: {
                                Label("Edit Email", systemImage: "envelope.fill")
                                    .font(.custom("FoundersGrotesk-Regular", size: 17))
                            }
                        }
                        HStack {
                            Button {
                                // Change Password
                                self.showPasswordAlert.toggle()
                            } label: {
                                Label("Edit Password", systemImage: "ellipsis.rectangle.fill")
                                    .font(.custom("FoundersGrotesk-Regular", size: 17))
                            }
                        }
                        .alert("Are you sure you want to change your password?", isPresented: $showPasswordAlert) {
                            Button(role: .cancel) {
                                
                            } label: {
                                Text("Cancel")
                            }
                            Button(role: .destructive) {
                                self.passwordChangedAlert.toggle()
                                do {
                                    auth.sendPasswordReset(withEmail: auth.currentUser!.email!) { error in
                                        if error == nil {
                                            passwordChangedAlert = true
                                        }
                                    }
                                }
                            } label: {
                                Text("Change Password")
                            }
                        }
                        .alert("Please check your email to reset your password", isPresented: $passwordChangedAlert){
                            Button("OK") {
                                passwordChangedAlert = false
                            }
                        }
                    }
                    .listItemTint(.white)
                    .listRowBackground(Color.white.opacity(0.2))

                    Section(header: Label("More Actions", systemImage: "ellipsis").foregroundColor(.white).opacity(0.5)) {
                        HStack {
                            Button {
                                // Clear Cache
                                clearCacheAlert.toggle()
                                SDImageCache.shared.clear(with: .all)
                            } label: {
                                Label("Clear Cache", systemImage: "trash.slash.circle")
                                    .font(.custom("FoundersGrotesk-Regular", size: 17))
                            }
                            .alert(isPresented: $clearCacheAlert) {
                                Alert(title: Text("Your cache was cleared."))
                            }
                        }
                        
                        HStack {
                            Button {
                                // Clear Search History
                                Task{
                                    let ref = Firestore.firestore()
                                        .collection("private")
                                        .document(Auth.auth().currentUser!.uid)
                                    try await ref
                                        .updateData([
                                            "searchHistory": []
                                        ])
                                    showSearchClearedAlert.toggle()
                                }
                            } label: {
                                Label("Clear Search History", systemImage: "magnifyingglass.circle.fill")
                                    .font(.custom("FoundersGrotesk-Regular", size: 17))
                            }
                            .alert(isPresented: $showSearchClearedAlert) {
                                Alert(title: Text("Your search history was cleared."))
                            }
                        }
                        
                        HStack {
                            Button {
                                // Logout
                                self.showLogoutAlert.toggle()
                            } label: {
                                Label("Log Out", systemImage: "arrowtriangle.backward.square.fill")
                                    .font(.custom("FoundersGrotesk-Regular", size: 17))
                            }
                        }
                        .alert("Are you sure you want to log out?", isPresented: $showLogoutAlert) {
                            Button(role: .cancel) {
                                
                            } label: {
                                Text("Cancel")
                            }
                            
                            Button(role: .destructive) {
                                do {
                                    try auth.signOut()
                                    loggedOut = true
                                } catch {
                                    print("already logged out")
                                }
                            } label: {
                                Text("Log Out")
                            }
                        }
                        
                        HStack {
                            Button {
                                // Delete Account
                                showDeleteAlert.toggle()
                            } label: {
                                Label("Delete Account", systemImage: "trash.circle.fill")
                                    .font(.custom("FoundersGrotesk-Regular", size: 17))
                            }
                        }
                        .alert("Are you sure?", isPresented: $showDeleteAlert, actions: {
                            Button(role: .cancel) {
                                showDeleteAlert.toggle()
                            } label: {
                                Text("Cancel")
                            }
                            
                            Button(role: .destructive) {
                                Task {
                                    try await deleteAccount()
                                }
                            } label: {
                                Text("Delete")
                            }
                        }, message: {
                            Text("This will delete all of your notes, books in your library, and data off of our servers. This action is irreversible.")
                        })
                    }
                    .listItemTint(.white)
                    .listRowBackground(Color.white.opacity(0.2))

                }
                .customAlert(manager: nameAlertManager, content: {
                    VStack {
                        Text("Would you like to change your name?").bold()
                        Text("This change may take a few seconds to propagate across our servers.")
                        TextField("Bruce Wayne", text: $newName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.name)
                    }
                }, buttons: [
                    .cancel(content: {
                        Text("Cancel")
                        .foregroundColor(.black)
                    }),
                    .regular(content: {
                        Text("Update")
                        .foregroundColor(.black)
                    }, action: {
                        if let userID = auth.currentUser?.uid {
                            Firestore.firestore()
                                .collection("users")
                                .document(userID)
                                .updateData([
                                    "name": newName
                                ], completion: { error in
                                    if error == nil {
                                        print("success")
                                    } else {
                                        print("ERROR CHNAGNG", error!.localizedDescription)
                                    }
                                })
                        } else {
                            print("no uid")
                        }
                    })
                ])
                .customAlert(manager: authAlertManager, content: {
                    VStack {
                        Text("Please reauthenticate your account").bold()
                        Text("To change your email, please login again.")
                        TextField("Bruce Wayne", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.emailAddress)
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.password)
                    }
                }, buttons: [
                    .cancel(content: {
                        Text("Cancel")
                        .foregroundColor(.black)
                        
                    }),
                    .regular(content: {
                        Text("Login")
                        .foregroundColor(.black)
                    }, action: {
                        let credential = EmailAuthProvider.credential(withEmail: username, password: password)
                        
                        Task {
                            do {
                                if let user = auth.currentUser {
                                    try await user.reauthenticate(with: credential)
                                    
                                    emailAlertManager.show()
                                }
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        }
                    })
                ])
                .customAlert(manager: emailAlertManager, content: {
                    VStack {
                        Text("Would you like to change your email?").bold()
                        Text("All future Athena communications will be sent to this email.")
                        TextField("bruce@wayne.com", text: $newEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.emailAddress)
                    }
                }, buttons: [
                    .cancel(content: {
                        Text("Cancel")
                    }),
                    .regular(content: {
                        Text("Update")
                    }, action: {
                        Task {
                            do {
                                if let user = auth.currentUser {
                                    try await user.updateEmail(to: newEmail)
                                    
                                    try await firestore
                                        .collection("private")
                                        .document(user.uid)
                                        .updateData([
                                            "email": newEmail
                                        ])
                                }
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        }
                    })
                ])
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                })
            }
        }
        .fullScreenCover(isPresented: $loggedOut) {
            // Shows OnboardingOne if the user logs out
            OnboardingOne()
        }
        .onAppear {
            if let userID = auth.currentUser?.uid {
                Task {
                    let publicDoc = try await firestore
                        .collection("users")
                        .document(userID)
                        .getDocument()
                    let publicData = publicDoc.data()
                    self.newName = publicData?["name"] as? String ?? ""
                    
                    let privateDoc = try await firestore
                        .collection("private")
                        .document(userID)
                        .getDocument()
                    let privateData = privateDoc.data()
                    self.newEmail = privateData?["email"] as? String ?? ""
                }
            }
        }
    }
    
    private func deleteAccount() async throws {
        if let userID = auth.currentUser?.uid {
            // Delete Firestore Public Data
            try await firestore
                .collection("users")
                .document(userID)
                .delete()
            
            // Delete Firestore Private Data
            try await firestore
                .collection("private")
                .document(userID)
                .delete()
            
            // Delete Notes
            let notesDocs = try await firestore
                .collection("notes")
                .whereField("creatorID", isEqualTo: userID)
                .getDocuments()
            
            for document in notesDocs.documents {
                try await firestore
                    .collection("notes")
                    .document(document.documentID)
                    .delete()
            }
            
            // Delete Already Read
            let arDocs = try await firestore
                .collection("alreadyRead")
                .whereField("readerID", isEqualTo: userID)
                .getDocuments()
            for document in arDocs.documents {
                try await firestore
                    .collection("alreadyRead")
                    .document(document.documentID)
                    .delete()
            }
            
            // Wishlist Notes
            let wishDocs = try await firestore
                .collection("wishlist")
                .whereField("readerID", isEqualTo: userID)
                .getDocuments()
            for document in wishDocs.documents {
                try await firestore
                    .collection("notes")
                    .document(document.documentID)
                    .delete()
            }
            
            // Currently Reading Notes
            let crDocs = try await firestore
                .collection("currentlyReading")
                .whereField("readerID", isEqualTo: userID)
                .getDocuments()
            for document in crDocs.documents {
                try await firestore
                    .collection("currentlyReading")
                    .document(document.documentID)
                    .delete()
            }
            
            // Delete Auth
            do {
                try await auth.currentUser?.delete()
                try auth.signOut()
                loggedOut = true
            } catch {
                print("already logged out")
            }
        } else {
            print("logged out")
            loggedOut = true
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
