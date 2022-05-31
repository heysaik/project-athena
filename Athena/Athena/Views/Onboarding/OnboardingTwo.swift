//
//  OnboardingTwo.swift
//  Athena
//
//  Created by Sai Kambampati on 4/13/22.
//

import SwiftUI

struct OnboardingTwo: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 24) {
                Spacer()
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .foregroundColor(.white.opacity(0.7))
                    .shadow(color: Color(red: 23/255, green: 197/255, blue: 1), radius: 10, x: 0, y: 0)
                    .padding(.horizontal)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Search for books worldwide")
                        .titleTwo()
                        .foregroundColor(.white)
                    Text("Athena has the latest information about any book. Powered by Google Books, Athena allows you to search for any book and add it to your library tracker.")
                        .titleFive()
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                // Go to next screen
                NavigationLink {
                    OnboardingThree()
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

struct OnboardingTwo_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTwo()
    }
}
