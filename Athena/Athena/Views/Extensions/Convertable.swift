//
//  Convertable.swift
//  Athena
//
//  Created by Sai Kambampati on 5/30/22.
//

import Foundation

// Custom protocol used for converting custom
// objects into a dictionary based representation.
// Helps store to Firestore.
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
