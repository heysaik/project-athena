//
//  OnboardingFour.swift
//  Athena
//
//  Created by Sai Kambampati on 4/9/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct OnboardingFour: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showHomeScreen = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showErrorAlert = false
    @State private var showLoadingView = false

    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 24) {
                Spacer()
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .foregroundColor(.white.opacity(0.7))
                    .shadow(color: Color(red: 23/255, green: 197/255, blue: 1), radius: 10, x: 0, y: 0)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Create an Account")
                        .titleTwo()
                        .foregroundColor(.white)
                    Text("Having an Athena account lets you login from any iOS or iPadOS device to quickly access your saved books, notes, and searches!")
                        .titleFive()
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Email", text: $email, prompt: Text("bruce@wayneenterprises.com"))
                        .font(.custom("FoundersGrotesk-Regular", size: 17))
                        .padding(.horizontal)
                        .keyboardType(.emailAddress)
                        .textCase(.lowercase)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 44)
                                .foregroundColor(.white.opacity(0.75))
                        )
                        .frame(height: 44)
                    
                    SecureField("Password", text: $password, prompt: Text("imbatman"))
                        .font(.custom("FoundersGrotesk-Regular", size: 17))
                        .padding(.horizontal)
                        .textCase(.lowercase)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 44)
                                .foregroundColor(.white.opacity(0.75))
                        )
                        .frame(height: 44)
                }
                .padding(.horizontal)

                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showLoadingView = true
                        }
                        
                        Task {
                            // Create Account
                            var authResult: AuthDataResult? = nil
                            do {
                                authResult = try await auth.createUser(withEmail: email, password: password)
                            } catch let error {
                                alertTitle = "Could not create account"
                                alertMessage = error.localizedDescription
                                showErrorAlert = true
                                showLoadingView = false
                                return
                            }
                            
                            if let authResult = authResult {
                                // Send email verification
                                try await authResult.user.sendEmailVerification()
                                
                                // Set Firestore Data
                                do {
                                    try await firestore
                                        .collection("users")
                                        .document(authResult.user.uid)
                                        .setData([
                                            "alreadyRead": [],
                                            "wishlist": [],
                                            "currentlyReading": [],
                                            "name": "Athena User"
                                        ])
                                } catch let error {
                                    alertTitle = "Could not create account"
                                    alertMessage = error.localizedDescription
                                    showErrorAlert = true
                                    showLoadingView = false
                                    return
                                }
                                
                                do {
                                    try await firestore
                                        .collection("private")
                                        .document(authResult.user.uid)
                                        .setData([
                                            "email": email,
                                            "insights": [],
                                            "searchHistory": []
                                        ])
                                } catch let error {
                                    alertTitle = "Could not create account"
                                    alertMessage = error.localizedDescription
                                    showErrorAlert = true
                                    showLoadingView = false
                                    return
                                }
                                
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showLoadingView = false
                                }
                                
                                // Show Home Screen
                                showHomeScreen.toggle()
                            }
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .frame(height: 44)
                                .foregroundColor(.white.opacity(0.5))
                            Text("Signup")
                                .headline()
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showLoadingView = true
                        }
                        
                        // Login
                        Task {
                            do {
                                _ = try await auth.signIn(withEmail: email, password: password)
                            } catch let error {
                                alertTitle = "Could not sign in"
                                alertMessage = error.localizedDescription
                                showErrorAlert = true
                                showLoadingView = false
                                return
                            }
                            
                            
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showLoadingView = false
                            }
                            showHomeScreen.toggle()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .frame(height: 44)
                                .foregroundColor(.white.opacity(0.5))
                            Text("Login")
                                .headline()
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showHomeScreen) {
            RootView()
        }
        .alert("An Error Occured", isPresented: $showErrorAlert) {
            Button {
                // Dismiss
            } label: {
                Text("OK")
            }

        } message: {
            Text(alertMessage)
        }
        .overlay {
            if showLoadingView {
                LoadingView()
            }
        }
    }
}

struct OnboardingFour_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFour()
    }
}
