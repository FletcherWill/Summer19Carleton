//
//  Setup.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/15/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import Foundation

class Setup {
    
    var pacingSelectable = false
    var copSelectable = false
    
    var experimentTitle: String?
    var experimenterName: String?
    var femaleNumber: String?
    var studNumber: String?
    var objectOne: String?
    var objectTwo: String?
    
    func updateSelectable() {
        if experimentTitle != nil && experimenterName != nil && !experimentTitle!.isEmpty && !experimenterName!.isEmpty {
            if femaleNumber != nil && studNumber != nil && !femaleNumber!.isEmpty && !studNumber!.isEmpty {
                pacingSelectable = true
            } else {
                pacingSelectable = false
            }
            if objectOne != nil && objectTwo != nil && !objectOne!.isEmpty && !objectTwo!.isEmpty && femaleNumber != nil && !femaleNumber!.isEmpty {
                copSelectable = true
            } else {
                copSelectable = false
            }
        } else {
            pacingSelectable = false
            copSelectable = false
        }
    }
    
    func updateValues(et: String?, en: String?, fn: String?, sn: String?, oo: String?, ot: String?) {
        experimentTitle = et
        experimenterName = en
        femaleNumber = fn
        studNumber = sn
        objectOne = oo
        objectTwo = ot
    }
    
}
