//
//  ProfileView.swift
//  Athena
//
//  Created by Logan Thompson on 4/19/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @State private var email = Auth.auth().currentUser!.email
    @State private var showAlreadyRead = true
    @State private var showLogoutAlert = false
    @State private var loggedOut = false
    
    var body: some View {
        NavigationView{
            ZStack {
                LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 1) {
                    Text(email!)
                        .font(.system(size: 25, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
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
                    Button {
                        // Edit Email
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
                    .padding(.vertical)
                    Spacer()
                    HStack{
                        // Had to place Button in between two "Spacers" in order to center
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
                .padding(.horizontal)
            }
            .navigationTitle("Profile")
            .fullScreenCover(isPresented: $loggedOut) { // Shows OnboardingOne if the user logs out
                            OnboardingOne()
            }

        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
