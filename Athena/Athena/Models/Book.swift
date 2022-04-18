//
//  Book.swift
//  Athena
//
//  Created by Sai Kambampati on 4/18/22.
//

import Foundation

// This structure is used to save 
struct Book: Identifiable, Codable {
    var id: String
    var title: String
    var authors: [String]
    var publisher: String
    var publishedDate: String
    var description: String
    var pageCount: Int
    var categories: [String]
    var isbn13: String?
    var isbn10: String?
    var imageLink: String
}
