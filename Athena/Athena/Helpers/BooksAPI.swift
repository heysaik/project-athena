//
//  BooksAPI.swift
//  Athena
//
//  Created by Sai Kambampati on 4/18/22.
//

import Foundation

final class GoogleBooksManager {
    static let shared = GoogleBooksManager()
        
    struct Constants {
        static let baseURL = "https://www.googleapis.com/books/v1/"
        static let key = "AIzaSyCXDYMyF5J3iehU30JJ-7yFq80hAKHr_jw"
    }
    
    private init() {}
    
    public func search(_ term: String) async throws -> [Book] {
        let searchURL = URL(string: "\(Constants.baseURL)volumes?q=\(term)&printType=books&key=\(Constants.key)&maxResults=20")!
        
        let request = URLRequest(url: searchURL)
        let (data, _) = try await URLSession.shared.data(for: request)
        let result = try JSON(data: data)
        
        if let books = (result["items"]).array {
            var results = [Book]()
            for book in books {
                results.append(
                    Book(
                        id: book["id"].stringValue,
                        title: book["volumeInfo"]["title"].stringValue,
                        authors: book["volumeInfo"]["authors"].arrayObject as? [String] ?? ["Anonymous Author"],
                        publisher: book["volumeInfo"]["publisher"].stringValue,
                        publishedDate: book["volumeInfo"]["publishedDate"].stringValue,
                        description: book["volumeInfo"]["description"].stringValue,
                        pageCount: book["volumeInfo"]["pageCount"].intValue,
                        categories: book["volumeInfo"]["categories"].arrayObject as? [String] ?? [],
                        imageLink: book["volumeInfo"]["imageLinks"]["thumbnail"].stringValue
                    )
                )
            }
            return results
        } else {
            return []
        }
    }
}
