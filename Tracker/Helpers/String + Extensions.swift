//
//  String + Extensions.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 30.01.2024.
//

import Foundation

extension String {
    
    var localized: String {
        NSLocalizedString(self, comment: "\(self) определен в Localizable.string")
    }
}
