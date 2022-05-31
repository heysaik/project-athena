//
//  SearchTerm.swift
//  Athena
//
//  Created by Sai Kambampati on 4/20/22.
//

import Foundation
import FirebaseFirestoreSwift

struct SearchTerm: Identifiable, Convertable, Hashable {
    var id: String
    var date: Date
}
