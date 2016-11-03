//
//  String+ASC.swift
//  Anti-Social Club
//
//  Created by Declan Hopkins on 11/3/16.
//  Copyright © 2016 UB Anti-Social Club. All rights reserved.
//

import Foundation

extension String {
    func isEmptyOrWhitespace() -> Bool {

        if(self.isEmpty) {
            return true
        }

        let trimmed = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmed == ""
    }
}
