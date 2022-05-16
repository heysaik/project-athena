//
//  Change Email.swift
//  Athena
//
//  Created by Kevin Crawford on 4/29/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Change_Email: View {
    @State private var newemail = ""
    @State private var password = ""
    @State private var showLoadingView = false
    @State private var user = Auth.auth().currentUser
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showErrorAlert = false
    @State private var emailAlert = false
    
    var body: some View {
        LinearGradient(colors: [Color(.displayP3, red: 0, green: 110/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
            .edgesIgnoringSafeArea(.all)
        VStack(alignment: .leading, spacing: 8) {
            TextField("New Email Adress", text: $newemail, prompt: Text("New Email Adress"))
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
            
            SecureField("Confirm Password", text: $password, prompt: Text("Current Password"))
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
        .navigationTitle("Edit Email")
        .navigationBarTitleDisplayMode(.inline)
        
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showLoadingView = true
                }
                
                Task {
                        // Change Email
                    let credential = EmailAuthProvider.credential(withEmail: Auth.auth().currentUser!.email!, password: password)
                    do {
                        try await user?.reauthenticate(with: credential)
                    } catch let error {
                        alertTitle = "Could not change email"
                        alertMessage = error.localizedDescription
                        showErrorAlert = true
                        showLoadingView = false
                        return
                    }
                    do {
                        try await user?.updateEmail(to: newemail)
                    } catch let error {
                        alertTitle = "Could not change email"
                        alertMessage = error.localizedDescription
                        showErrorAlert = true
                        showLoadingView = false
                        return
                    }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showLoadingView = false
                    }
                    emailAlert = true
                }
            }
            ) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .frame(height: 44)
                        .foregroundColor(.white.opacity(0.5))
                    Text("Change Email")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .alert("Email has been successfully changed", isPresented: $emailAlert) {
                Button("OK") {
                    // At this point I want to refresh the email so it doesn't crash when logging out
                }
            }
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .alert(alertTitle, isPresented: $showErrorAlert) {
            Button {
                // Dismiss
            } label: {
                Text("OK")
            }

        } message: {
            Text(alertMessage)
        }
    }
}

struct Change_Email_Previews: PreviewProvider {
    static var previews: some View {
        Change_Email()
    }
}
