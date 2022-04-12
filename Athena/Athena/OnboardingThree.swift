//
//  OnboardingThree.swift
//  Athena
//
//  Created by Kevin Crawford on 4/12/22.
//

import SwiftUI

struct OnboardingThree: View {
    var body: some View {
        NavigationView{
        ZStack {
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 24) {
                Spacer()
                Image("icon-bookmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Jot down your amazing thoughts")
                        .font(.system(.title, design: .rounded)).bold()
                        .foregroundColor(.white)
                    Text("Have a quote that you like? Athena makes it easy to store your notes and bookmark your ideas while reading")
                        .font(.system(.title3, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                NavigationLink(destination: OnboardingFour()){
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .frame(height: 44)
                            .foregroundColor(.white.opacity(0.5))
                        Text("Next")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
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

struct OnboardingThree_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingThree()
    }
}
