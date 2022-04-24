//
//  Book.swift
//  Athena
//
//  Created by Sai Kambampati on 4/18/22.
//

import Foundation

// This structure is used to save 
struct Book: Identifiable, Convertable, Equatable {
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
    var googleBooksRating: Float
}

protocol Convertable: Codable {}
extension Convertable {
    func convertToDict() -> Dictionary<String, Any>? {
        var dict: Dictionary<String, Any>? = nil
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>
        } catch {
            print(error)
        }

        return dict
    }
}
