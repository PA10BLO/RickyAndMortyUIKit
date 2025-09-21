//
//  String+Additions.swift
//  RickyAndMortyUIKit
//
//  Created by Pablo on 20/9/25.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    public static var empty: String {
        return ""
    }
}
