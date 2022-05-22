//
//  RootView.swift
//  Athena
//
//  Created by Sai Kambampati on 4/13/22.
//

import SwiftUI

struct RootView: View {
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "FoundersGrotesk-Bold", size: 34)!]
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "FoundersGrotesk-Medium", size: 20)!]
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FoundersGrotesk-Medium", size: 11)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FoundersGrotesk-Medium", size: 11)!], for: .selected)
    }
    
    var body: some View {
        TabView {
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .preferredColorScheme(.dark)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
