//
//  String.swift
//  Athena
//
//  Created by Sai Kambampati on 5/30/22.
//

import Foundation

extension String {
    func removeCurlFromPreview() -> String {
        return self.replacingOccurrences(of: "&edge=curl", with: "")
    }
}
