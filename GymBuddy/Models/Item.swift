//
//  Item.swift
//  GymBuddy
//
//  Created by Vikas Bishnoi on 16/04/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
