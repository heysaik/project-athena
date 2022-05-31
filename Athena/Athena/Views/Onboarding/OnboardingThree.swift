//
//  OnboardingThree.swift
//  Athena
//
//  Created by Kevin Crawford on 4/12/22.
//

import SwiftUI

struct OnboardingThree: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 24) {
                Spacer()
                Image(systemName: "note.text")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .foregroundColor(.white.opacity(0.7))
                    .shadow(color: Color(red: 23/255, green: 197/255, blue: 1), radius: 10, x: 0, y: 0)
                    .padding(.horizontal)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Jot down your amazing thoughts")
                        .titleTwo()
                        .foregroundColor(.white)
                    Text("Have a quote that you like? Want to note down a quick reflection? Athena makes it easy to store your notes and ideas while reading. We want to bring the technological features of ebooks to readers who love physical hardcovers.")
                        .titleFive()
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                // Go to next screen
                NavigationLink {
                    OnboardingFour()
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
        .navigationBarHidden(true)
    }
}

struct OnboardingThree_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingThree()
    }
}
