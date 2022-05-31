//
//  Array.swift
//  Athena
//
//  Created by Sai Kambampati on 5/30/22.
//

import Foundation

extension Array where Element == Book {
    func sortBy(option: SortOptions) -> [Book] {
        if option == .title {
            return self.sorted(by: {$0.title < $1.title})
        } else if option == .author {
            return self.sorted(by: {$0.authors[0] < $1.authors[0]})
        } else if option == .progress {
            return self.sorted(by: {(Double($0.pagesRead ?? 0)/Double($0.pageCount) * 100) > (Double($1.pagesRead ?? 0)/Double($1.pageCount) * 100)})
        } else {
            return self
        }
    }
}
