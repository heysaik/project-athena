//
//  BooksAPI.swift
//  Athena
//
//  Created by Sai Kambampati on 4/18/22.
//

import Foundation
import SwiftyJSON

final class GoogleBooksManager {
    static let shared = GoogleBooksManager()
        
    struct Constants {
        static let baseURL = "https://www.googleapis.com/books/v1/"
        static let key = "AIzaSyCXDYMyF5J3iehU30JJ-7yFq80hAKHr_jw"
    }
    
    private init() {}
    
    public func search(_ term: String) async throws -> [Book] {
        let trimmedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
        if let searchURL = URL(string: "\(Constants.baseURL)volumes?q=\(trimmedTerm)&printType=books&key=\(Constants.key)&maxResults=20") {
            let request = URLRequest(url: searchURL)
            let (data, _) = try await URLSession.shared.data(for: request)
            let result = try JSON(data: data)
            
            if let books = (result["items"]).array {
                var results = [Book]()
                for book in books {
                    var b = Book(
                        id: book["id"].stringValue,
                        docID: UUID().uuidString,
                        title: book["volumeInfo"]["title"].stringValue,
                        authors: book["volumeInfo"]["authors"].arrayObject as? [String] ?? ["Anonymous Author"],
                        publisher: book["volumeInfo"]["publisher"].stringValue,
                        publishedDate: book["volumeInfo"]["publishedDate"].stringValue,
                        description: book["volumeInfo"]["description"].stringValue,
                        pageCount: book["volumeInfo"]["pageCount"].intValue,
                        categories: book["volumeInfo"]["categories"].arrayObject as? [String] ?? [],
                        imageLink: book["volumeInfo"]["imageLinks"]["thumbnail"].stringValue,
                        googleBooksRating: book["volumeInfo"]["averageRating"].floatValue
                    )
                    let identifiers = book["volumeInfo"]["industryIdentifiers"].arrayValue
                    for identifier in identifiers {
                        if identifier["type"] == "ISBN_13" {
                            b.isbn13 = identifier["identifier"].stringValue
                        } else if identifier["type"] == "ISBN_10" {
                            b.isbn10 = identifier["identifier"].stringValue
                        }
                    }
                    
                    results.append(b)
                }
                return results
            }
        }
        return []
    }
    
    public func recommendedBooks(from author: String) async throws -> [Book] {
        let plusAuthor = author.replacingOccurrences(of: " ", with: "+").trimmingCharacters(in: .whitespacesAndNewlines)
        if let searchURL = URL(string: "\(Constants.baseURL)volumes?q=inauthor:\(plusAuthor)&printType=books&maxResults=5") {
            let request = URLRequest(url: searchURL)
            let (data, _) = try await URLSession.shared.data(for: request)
            let result = try JSON(data: data)
            
            if let books = (result["items"]).array {
                var results = [Book]()
                for book in books {
                    var currentBook = Book(
                        id: book["id"].stringValue,
                        docID: UUID().uuidString,
                        title: book["volumeInfo"]["title"].stringValue,
                        authors: book["volumeInfo"]["authors"].arrayObject as? [String] ?? ["Anonymous Author"],
                        publisher: book["volumeInfo"]["publisher"].stringValue,
                        publishedDate: book["volumeInfo"]["publishedDate"].stringValue,
                        description: book["volumeInfo"]["description"].stringValue,
                        pageCount: book["volumeInfo"]["pageCount"].intValue,
                        categories: book["volumeInfo"]["categories"].arrayObject as? [String] ?? [],
                        imageLink: book["volumeInfo"]["imageLinks"]["thumbnail"].stringValue,
                        googleBooksRating: book["volumeInfo"]["averageRating"].floatValue
                    )
                    let identifiers = book["volumeInfo"]["industryIdentifiers"].arrayValue
                    for identifier in identifiers {
                        if identifier["type"] == "ISBN_13" {
                            currentBook.isbn13 = identifier["identifier"].stringValue
                        } else if identifier["type"] == "ISBN_10" {
                            currentBook.isbn10 = identifier["identifier"].stringValue
                        }
                    }
                    
                    results.append(currentBook)
                }
                return results
            }
        }
        return []
    }
}
