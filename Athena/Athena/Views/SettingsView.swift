//
//  SettingsView.swift
//  Athena
//
//  Created by Sai Kambampati on 5/7/22.
//

import SwiftUI
import SDWebImage
import FirebaseAuth

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showLogoutAlert = false
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
                                // Push Notifications
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
                            } label: {
                                Label("Edit Password", systemImage: "ellipsis.rectangle.fill")
                                    .font(.system(size: 17, design: .rounded))
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
                                // Clear Cache
                                self.showLogoutAlert.toggle()
                            } label: {
                                Label("Log Out", systemImage: "arrowtriangle.backward.square.fill")
                                    .font(.system(size: 17, design: .rounded))
                                
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
                        
                        HStack {
                            Button {
                                // Delete Account
                            } label: {
                                Label("Delete Account", systemImage: "trash.circle.fill")
                                    .font(.system(size: 17, design: .rounded))
                                
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
