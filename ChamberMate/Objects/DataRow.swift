//
//  PaceDataRow.swift
//  ChamberMate
//
//  Created by Will Fletcher on 8/7/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import Foundation

// struct used with editdata.data
struct DataRow {
    var event: String
    var eventType: Int
    var time: Int
    
    init(event: String, eventType: Int, time: Int) {
        self.event = event
        self.eventType = eventType
        self.time = time
    }
}
