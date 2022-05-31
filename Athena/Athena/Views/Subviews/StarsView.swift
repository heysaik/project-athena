//
//  StarsView.swift
//  Athena
//
//  Created by Sai Kambampati on 4/23/22.
//

import SwiftUI

struct StarsView: View {
    private static let MAX_RATING: Float = 5 // Defines upper limit of the rating
    private static let COLOR = Color(red: 1, green: 226/255, blue: 38/255) // The color of the stars
    
    let rating: Float
    private let fullCount: Int
    private let emptyCount: Int
    private let halfFullCount: Int
    
    init(rating: Float) {
        self.rating = rating
        fullCount = Int(rating)
        emptyCount = Int(StarsView.MAX_RATING - rating)
        halfFullCount = (Float(fullCount + emptyCount) < StarsView.MAX_RATING) ? 1 : 0
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<fullCount, id:\.self) { _ in
                self.fullStar
            }
            ForEach(0..<halfFullCount, id:\.self) { _ in
                self.halfFullStar
            }
            ForEach(0..<emptyCount, id:\.self) { _ in
                self.emptyStar
            }
        }
    }
    
    private var fullStar: some View {
        Image(systemName: "star.fill")
            .foregroundColor(StarsView.COLOR)
    }
    
    private var halfFullStar: some View {
        Image(systemName: "star.lefthalf.fill")
            .foregroundColor(StarsView.COLOR)
    }
    
    private var emptyStar: some View {
        Image(systemName: "star")
            .foregroundColor(StarsView.COLOR)
    }
}
