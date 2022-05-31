//
//  RootView.swift
//  Athena
//
//  Created by Sai Kambampati on 4/13/22.
//

import SwiftUI

struct RootView: View {
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "FoundersGrotesk-Bold", size: 34)!, .foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "FoundersGrotesk-Medium", size: 20)!, .foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor(red: 0, green: 145/255, blue: 1, alpha: 1)
        UITabBarItem.appearance().setTitleTextAttributes([.font: UIFont(name: "FoundersGrotesk-Medium", size: 11)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.font: UIFont(name: "FoundersGrotesk-Medium", size: 11)!], for: .selected)
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.5)
        UITabBar.appearance().backgroundColor = UIColor(red: 0, green: 68/255, blue: 215/255, alpha: 1)
        UITabBar.appearance().barTintColor = UIColor(red: 0, green: 68/255, blue: 215/255, alpha: 1)
    }
    
    @StateObject private var viewModel = RootViewModel()
    
    var body: some View {
        TabView {
            LibraryView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }

            SearchView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            NotesView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }

            ProfileView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                        
                }

        }
        .preferredColorScheme(.dark)
        .tint(.white)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
