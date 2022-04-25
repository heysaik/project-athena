//
//  NotesView.swift
//  Athena
//
//  Created by Sai Kambampati on 4/13/22.
//


import SwiftUI

struct NotesView: View {
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                    .edgesIgnoringSafeArea(.all)
                            .navigationTitle("Notes")
                            .toolbar {
                                ToolbarItemGroup(placement: .navigationBarTrailing) {
                                    Button("Create New Note") {
                                    }
                                }
                            }
                VStack(alignment: .leading, spacing: 1) {
                    Spacer()
                    
                    Text("Currently Reading")
                        .font(.system(size: 25, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                            ScrollView {
                                 NavigationLink(
                                        destination:Text("TKAM NOTES"),
                                        label: {
                                        ZStack(alignment: .leading){
                                            RoundedRectangle(cornerRadius: 0)
                                                .frame(height: 35)
                                                .foregroundColor(.white.opacity(0.2))
                                            Text("To Kill a Mockingbird")
                                                .font(.system(size: 20, design: .rounded)).bold()
                                                .foregroundColor(.white)
                                                .frame(alignment: .leading)
                                                .padding(10)
                                            
                                        }
                                })
                                NavigationLink(
                                    destination:Text("GSAW NOTES"),
                                     label: {
                                    ZStack(alignment: .leading){
                                        RoundedRectangle(cornerRadius: 0)
                                            .frame(height: 35)
                                            .foregroundColor(.white.opacity(0.2))
                                        Text("Go Set a Watchman")
                                            .font(.system(size: 20, design: .rounded)).bold()
                                            .foregroundColor(.white)
                                            .frame(alignment: .leading)
                                            .padding(10)
                                        
                                    }
                                })
                            }
                        Divider()
                        Text("Already Read")
                            .font(.system(size: 25, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                                    ScrollView {
                                        NavigationLink(
                                               destination:Text("TROAL NOTES"),
                                               label: {
                                                ZStack(alignment: .leading){
                                                    RoundedRectangle(cornerRadius: 0)
                                                        .frame(height: 35)
                                                        .foregroundColor(.white.opacity(0.2))
                                                    Text("The Ride of a Lifetime")
                                                        .font(.system(size: 20, design: .rounded)).bold()
                                                        .foregroundColor(.white)
                                                        .frame(alignment: .leading)
                                                        .padding(10)
                                                }
                                        })
                                        NavigationLink(
                                               destination:Text("CTBRD NOTES"),
                                               label: {
                                                ZStack(alignment: .leading){
                                                    RoundedRectangle(cornerRadius: 0)
                                                        .frame(height: 35)
                                                        .foregroundColor(.white.opacity(0.2))
                                                    Text("Clifford The Big Red Dog")
                                                        .font(.system(size: 20, design: .rounded)).bold()
                                                        .foregroundColor(.white)
                                                        .frame(alignment: .leading)
                                                        .padding(10)
                                                }
                                        })
                                    }
                }
            }
            
        }
    }
}

 
struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView()
    }
}

