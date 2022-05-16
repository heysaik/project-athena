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

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    @State private var showEmailAlert = false
    @State private var loggedOut = false
    
    // Used to show the gradient
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                    .edgesIgnoringSafeArea(.all)
                Form {
                    Section(header: Label("About You", systemImage: "list.bullet.rectangle.fill")) {
                        HStack {
                            NavigationLink {
                                // Show Insights
                            } label: {
                                Label("Insights", systemImage: "chart.xyaxis.line")
                                    .font(.system(size: 17, design: .rounded))
                            }
                        }
                        HStack {
                            NavigationLink {
                                NotificationsView()
                            } label: {
                                Label("Push Notifications", systemImage: "bell.badge.fill")
                                    .font(.system(size: 17, design: .rounded))
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.2))
                    
                    Section(header: Label("Privacy and Security", systemImage: "lock.fill")) {
                        HStack {
                            Button {
                                // Edit Name
                            } label: {
                                Label("Edit Name", systemImage: "person.fill")
                                    .font(.system(size: 17, design: .rounded))
                                
                            }
                        }
                        HStack {
                            NavigationLink {
                                // Edit Email
                                Change_Email()
                            } label: {
                                Label("Edit Email", systemImage: "envelope.fill")
                                    .font(.system(size: 17, design: .rounded))
                            }
                        }
                        HStack {
                            Button {
                                // Change Password
                                do{
                                    Auth.auth().sendPasswordReset(withEmail: Auth.auth().currentUser!.email!) { error in
                                        if error == nil{
                                            showEmailAlert = true
                                        }
                                    }
                                }
                            } label: {
                                Label("Edit Password", systemImage: "ellipsis.rectangle.fill")
                                    .font(.system(size: 17, design: .rounded))
                            }
                        }
                        .alert("An email to change your password has been sent to \(Auth.auth().currentUser!.email!)", isPresented: $showEmailAlert){
                            Button("OK") {
                                showEmailAlert = false
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.2))

                    Section(header: Label("More Actions", systemImage: "ellipsis")) {
                        HStack {
                            Button {
                                // Clear Cache
                                SDImageCache.shared.clear(with: .all)
                            } label: {
                                Label("Clear Cache", systemImage: "trash.slash.circle")
                                    .font(.system(size: 17, design: .rounded))
                            }
                        }
                        
                        HStack {
                            Button {
                                // Logout
                                self.showLogoutAlert.toggle()
                            } label: {
                                Label("Log Out", systemImage: "arrowtriangle.backward.square.fill")
                                    .font(.system(size: 17, design: .rounded))
                                
                            }
                        }
                        .alert("Are you sure you want to log out?", isPresented: $showLogoutAlert) {
                            Button(role: .cancel) {
                                
                            } label: {
                                Text("Cancel")
                            }

                            Button(role: .cancel) {
                                do {
                                    try Auth.auth().signOut()
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
                                    .font(.system(size: 17, design: .rounded))
                                
                            }
                        }
                        .alert("Are you sure you want to log out?", isPresented: $showDeleteAlert) {
                            
                            Button(role: .cancel) {
                                showDeleteAlert.toggle()
                            } label: {
                                Text("Cancel")
                            }

                            Button(role: .destructive) {
                                Task {
                                    if let userID = Auth.auth().currentUser?.uid {
                                        // Delete Firestore Public Data
                                        try await Firestore.firestore()
                                            .collection("users")
                                            .document(userID)
                                            .delete()
                                        
                                        // Delete Firestore Private Data
                                        try await Firestore.firestore()
                                            .collection("private")
                                            .document(userID)
                                            .delete()
                                        
                                        // Delete Notes
                                        let notesDocs = try await Firestore.firestore()
                                            .collection("notes")
                                            .whereField("creatorID", isEqualTo: userID)
                                            .getDocuments()
                                        for document in notesDocs.documents {
                                            try await Firestore.firestore()
                                                .collection("notes")
                                                .document(document.documentID)
                                                .delete()
                                        }
                                        
                                        // Delete Already Read
                                        let arDocs = try await Firestore.firestore()
                                            .collection("alreadyRead")
                                            .whereField("readerID", isEqualTo: userID)
                                            .getDocuments()
                                        for document in arDocs.documents {
                                            try await Firestore.firestore()
                                                .collection("alreadyRead")
                                                .document(document.documentID)
                                                .delete()
                                        }
                                        
                                        // Wishlist Notes
                                        let wishDocs = try await Firestore.firestore()
                                            .collection("wishlist")
                                            .whereField("readerID", isEqualTo: userID)
                                            .getDocuments()
                                        for document in wishDocs.documents {
                                            try await Firestore.firestore()
                                                .collection("notes")
                                                .document(document.documentID)
                                                .delete()
                                        }
                                        
                                        // Currently Reading Notes
                                        let crDocs = try await Firestore.firestore()
                                            .collection("currentlyReading")
                                            .whereField("creatorID", isEqualTo: userID)
                                            .getDocuments()
                                        for document in crDocs.documents {
                                            try await Firestore.firestore()
                                                .collection("currentlyReading")
                                                .document(document.documentID)
                                                .delete()
                                        }
                                        
                                        // Delete Auth
                                        do {
                                            try Auth.auth().signOut()
                                            try await Auth.auth().currentUser?.delete()
                                            loggedOut = true
                                        } catch {
                                            print("already logged out")
                                        }
                                    } else {
                                        print("logged out")
                                        loggedOut = true
                                    }
                                }
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.2))

                }
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
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
