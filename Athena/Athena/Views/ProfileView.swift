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
    @State private var user = Auth.auth().currentUser
    @State private var showAlreadyRead = true
    @State private var showSettingsView = false
    
    var body: some View {
        NavigationView{
            ZStack {
                LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 8) {
                    Text(email!)
                        .font(.system(size: 25, design: .rounded))
                        .foregroundColor(.white)
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
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile")
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
