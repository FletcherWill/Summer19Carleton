//
//  Pace.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/15/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import Foundation

struct Pace {
    
    var time: Int
    var timerRunning: Bool
    var timeToDisplay: String {
        return (Double(time)).asString(style: .positional)
    }
    var showButtons: Bool {return isIn && timerRunning}
    var isIn: Bool
    
    init() {
        self.time = 0
        self.timerRunning = false
        self.isIn = false
    }
    
    init(time: Int) {
        self.time = time
        self.timerRunning = false
        self.isIn = false
    }
}

private extension Double {
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = style
        guard let formattedString = formatter.string(from: self) else { return "" }
        return formattedString
    }
}
