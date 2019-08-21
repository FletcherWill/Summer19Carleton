//
//  COP.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/22/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import Foundation

//model for cop
struct COP {
    var time: Int
    var timerRunning: Bool
    var timeToDisplay: String {
        return (Double(time)).asString(style: .positional)
    }
    var inCenter: Bool
    var objectOne: String
    var objectTwo: String
    
    init(objOne: String, objTwo: String) {
        self.time = 0
        self.timerRunning = false
        self.inCenter = true
        self.objectOne = objOne
        self.objectTwo = objTwo
    }
    
    init(time: Int, objOne: String, objTwo: String) {
        self.time = time
        self.timerRunning = false
        self.inCenter = true
        self.objectOne = objOne
        self.objectTwo = objTwo
    }
}

//converts double to a string displaying time
private extension Double {
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = style
        guard let formattedString = formatter.string(from: self) else { return "" }
        return formattedString
    }
}
