//
//  ProfileView.swift
//  Athena
//
//  Created by Logan Thompson on 4/19/22.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.displayP3, red: 0, green: 145/255, blue: 1, opacity: 1.0), Color(.displayP3, red: 0, green: 68/255, blue: 215/255, opacity: 1.0)], startPoint: .topLeading, endPoint: .center)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 24) {
                Text("Profile")
                    .font(.system(size:40, design: .rounded)).bold()
                    .foregroundColor(.white)
                Text("email")
                    .font(.system(size: 25, design: .rounded))
                    .foregroundColor(.white)
                ZStack{
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 30)
                        .foregroundColor(.white.opacity(0.3))
                    Text("Edit Name")
                        .font(.system(size: 20, design: .rounded)).bold()
                        .foregroundColor(.white)
                        .frame(alignment: .leading) // not working :/
                }
                ZStack{
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 30)
                        .foregroundColor(.white.opacity(0.3))
                    Text("Edit Email")
                        .font(.system(size: 20, design: .rounded)).bold()
                        .foregroundColor(.white)
                        .frame(alignment: .leading) // not working :/
                }
                ZStack{
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 30)
                        .foregroundColor(.white.opacity(0.3))
                    Text("Insights")
                        .font(.system(size: 20, design: .rounded)).bold()
                        .foregroundColor(.white)
                        .frame(alignment: .leading) // not working :/
                }
                ZStack{
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 30)
                        .foregroundColor(.white.opacity(0.3))
                    Text("Push Notifications")
                        .font(.system(size: 20, design: .rounded)).bold()
                        .foregroundColor(.white)
                        .frame(alignment: .leading) // not working :/
                }
                ZStack{
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 30)
                        .foregroundColor(.white.opacity(0.3))
                    Text("Clear Cache")
                        .font(.system(size: 20, design: .rounded)).bold()
                        .foregroundColor(.white)
                        .frame(alignment: .leading) // not working :/
                }
                HStack(alignment: .top, spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(height: 22)
                            .foregroundColor(.white.opacity(1))
                        Text("Already Read")
                            .font(.system(size: 20, design: .rounded))
                            .foregroundColor(.black)
                    }
                    ZStack{
                        RoundedRectangle(cornerRadius: 5)
                            .frame(height: 22)
                            .foregroundColor(.white.opacity(0))
                        Text("Wishlist")
                            .font(.system(size: 20, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.vertical)
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
