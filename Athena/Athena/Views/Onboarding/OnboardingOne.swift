//
//  OnboardingOne.swift
//  Athena
//
//  Created by Sai Kambampati on 4/6/22.
//

import SwiftUI

struct OnboardingOne: View {
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 24) {
                    Spacer()
                    Image("icon-book")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome to Athena")
                            .titleTwo()
                            .foregroundColor(.white)
                        Text("Athena is the app for readers around the world, helping you keep track of the books you've already read, are currently reading, and wish to read. We want to encourage you to build the habit of reading.")
                            .titleFive()
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    // Go to next screen
                    NavigationLink {
                        OnboardingTwo()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .frame(height: 44)
                                .foregroundColor(.white.opacity(0.5))
                            Text("Next")
                                .headline()
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingOne()
    }
}
