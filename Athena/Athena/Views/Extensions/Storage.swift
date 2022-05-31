//
//  Storage.swift
//  Athena
//
//  Created by Sai Kambampati on 5/30/22.
//

import Foundation

// Custom class that helps UserDefaults archive and load date value objects
class Storage: NSObject {
    static func archiveDate(object: Date) -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
            return data
        } catch {
            fatalError("Can't encode data: \(error)")
        }
        
    }
    
    static func loadDate(data: Data) -> Date {
        do {
            guard let date = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Date else {
                return Date()
            }
            return date
        } catch {
            fatalError("loadDate - Can't encode data: \(error)")
        }
    }
}
