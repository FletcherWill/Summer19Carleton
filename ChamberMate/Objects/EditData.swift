//
//  EditData.swift
//  ChamberMate
//
//  Created by Will Fletcher on 8/7/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import Foundation

class EditData {
    
    var data: [DataRow]
    var flags: [Int]
    
    init(data: [DataRow], flags: [Int]) {
        self.data = data
        self.flags = flags
    }
}
