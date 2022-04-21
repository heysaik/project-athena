//
//  LibraryView.swift
//  Athena
//
//  Created by Sai Kambampati on 4/13/22.
//

import SwiftUI

struct LibraryView: View {
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                LinearGradient(
                    colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)],
                    startPoint: .topLeading,
                    endPoint: .center
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Currently Reading")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .padding(.horizontal)
                    ScrollView(.horizontal) {
                        VStack(alignment: .leading, spacing: 24) {
                            Image("book-cover")
                                .resizable()
                                .aspectRatio(0.66, contentMode: .fill)
                                .frame(height: geometry.size.height * 0.7)
                                .cornerRadius(5, corners: [.topLeft, .bottomLeft])
                                .cornerRadius(13, corners: [.bottomRight, .topRight])
                                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("The Ride of a Lifetime")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .semibold, design: .default))
                                    Spacer()
                                    // TODO: Mini Progress View Goes Here
                                }
                                
                                HStack {
                                    Text("Robert Iger")
                                        .font(.system(size: 16, weight: .light, design: .default))
                                        .foregroundColor(.white)
                                    Spacer()
                                    
                                    // TODO: We can add this when we get to ratings
        //                            ForEach(0..<5) { i in
        //                                Image(systemName: "star.fill")
        //                                    .font(.system(size: 16))
        //                                    .foregroundColor(.yellow)
        //                            }
                                }
                            }
                            .padding(.bottom)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Library")
            .tint(.white)
        }
        
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
