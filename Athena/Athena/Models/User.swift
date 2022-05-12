//
//  User.swift
//  Athena
//
//  Created by Sai Kambampati on 4/18/22.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
}
