//
//  NotesView.swift
//  Athena
//
//  Created by Sai Kambampati on 4/13/22.
//


import SwiftUI

struct NotesView: View {
    @State private var notesText = ""
    @State private var notesText1 = ""
    @State private var notesText2 = ""
    @State private var notesText3 = ""
    @State private var text = ""

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
                    
                    Text("Currently Reading")  //split into two categories
                        .font(.system(size: 25, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                            ScrollView {
                                NavigationLink{
//                                        destination:Text("TKAM NOTES"
                                    VStack(alignment: .leading){
                                        
                                        
                                                       Text("TKAM NOTE 1")
                                                           .font(.title)
                                                       CustomTextEditor.init(placeholder: "Start typing..", text: $text)
                                                           .font(.body)
                                                           .background(Color(UIColor.blue))
                                                           .accentColor(.green)
                                                           .frame(height: 400)
                                                           .cornerRadius(8)
                                                       Spacer()
                                                   }.padding()
                                            
                                    
                                }

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
                                }
                                NavigationLink{
                                    TextEditor(text: $notesText1)
                                }
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
                                }
                            }
                        Divider()
                        Text("Already Read")
                            .font(.system(size: 25, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                                    ScrollView {
                                        NavigationLink{
                                            TextEditor(text: $notesText2)
                                        }

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
                                        }
                                        NavigationLink{
                                            TextEditor(text: $notesText3)
                                            }
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
                                        }
                                    }
                }
            }
            
        }
    }
}

struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    let internalPadding: CGFloat = 5
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty  {
                Text(placeholder)
                    .foregroundColor(Color.primary.opacity(0.25))
                    .padding(EdgeInsets(top: 7, leading: 4, bottom: 0, trailing: 0))
                    .padding(internalPadding)
            }
            TextEditor(text: $text)
                .padding(internalPadding)
        }.onAppear() {
            UITextView.appearance().backgroundColor = .clear
        }.onDisappear() {
            UITextView.appearance().backgroundColor = nil
        }
    }
}
 
struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView()
    }
}

