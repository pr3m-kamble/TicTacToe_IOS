//
//  Item.swift
//  TicTacToeGame
//
//  Created by Prem kamble on 23/02/25.
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
