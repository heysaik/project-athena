//
//  Note.swift
//  Athena
//
//  Created by Sai Kambampati on 5/7/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Note: Identifiable, Convertable, Equatable {
    @DocumentID var id: String?
    var title: String
    var note: String
    var createdAt: Date
    var creatorID: String
    var editedAt: Date
    var book: Book?
}
