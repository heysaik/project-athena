//
//  OnboardingFour.swift
//  Athena
//
//  Created by Sai Kambampati on 4/9/22.
//

import SwiftUI
import FirebaseAuth

struct OnboardingFour: View {
    @State private var email = ""
    @State private var password = ""
    
    private let auth = Auth.auth()
    
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
                    Text("Accessible on any device")
                        .font(.system(.title, design: .rounded)).bold()
                        .foregroundColor(.white)
                    Text("Access your account from any device by creating an account to save your books, notes, and searches! ")
                        .font(.system(.title3, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Email", text: $email, prompt: Text("bruce@wayne.com"))
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
                    
                    SecureField("Password", text: $password, prompt: Text("checkonetwo"))
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
                        Task {
                            // Create Account
                            let authResult = try await auth.createUser(withEmail: email, password: password)
                            
                            // Send email verification
                            try await authResult.user.sendEmailVerification()
                            
                            // TODO: Segue to home screen
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .frame(height: 44)
                                .foregroundColor(.white.opacity(0.5))
                            Text("Signup")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Button(action: {
                        // Login
                        Task {
                            _ = try await auth.signIn(withEmail: email, password: password)
                            
                            // TODO: Segue to home screen
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .frame(height: 44)
                                .foregroundColor(.white.opacity(0.5))
                            Text("Login")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
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
    }
}

struct OnboardingFour_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFour()
    }
}
