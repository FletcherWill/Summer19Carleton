//
//  DatabaseManager.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/16/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import Foundation
import SQLite


// Database manager keeps track of all the data that is saved by ChamberMate. Currently it allows for 5 tests to be saved at once. It consists of a master table which keeps track of information about the tests that exist and one table for each experiment that keeps track of the events that have occured in the experiment. An event is anything that happens in the experiment: mount, ears, flag, etc.
//If you edit how database stores data, you should delete app from ipads and reinstall new version instead of just updating. Otherwise the database that is expected is the updated one and the existing database is the old one which causes issues (same goes for simulator on computor)
class DatabaseManager {

    var database: Connection!
    // remebers Id of experiment being worked on. indexing starts at 1. It is set to 0 since no test is being worked on when chambermate loads
    var currID = 0
    // returns first unused id, 1 through 5. If there are 5 tests already saved returns nil. For example if there are tests saved at 1,2, and 4 it will return 3
    var getID: Int? {
        let ids = self.getExperimentIDs()
        for num in 1...5 {
            if !(ids.contains(num)) {
                return num
            }
        }
        return nil
    }
    
    let masterTable = Table("masterTable")
    let id = Expression<Int>("id")
    let isPace = Expression<Bool>("isPace")
    let name = Expression<String>("name")
    let experimenter = Expression<String>("experimenter")
    let firstInfo = Expression<String>("firstInfo")
    let secondInfo = Expression<String>("secondInfo")
    let femNumCOP = Expression<String>("femNumCOP")
    let dataTime = Expression<String>("dataTime")
    
    // where tests are stored. I recently found ount that Dr. Meerts calls these tests not experiments
    let experiments = [Table("experiment1"), Table("experiment2"),Table("experiment3"),Table("experiment4"),Table("experiment5")]
    
    let event =  Expression<String>("event")
    let eventType = Expression<Int>("eventType")
    let time = Expression<Int>("time")
    
    // allows chambermate to comunicate with database. Called when experiment loads
    func createDB() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("users").appendingPathExtension("sqlite3")
            let db = try Connection(fileUrl.path)
            database = db
            print("created database")
        } catch {
            print(error)
        }
    }
    
    func createMasterTable() {
        let createTable = masterTable.create { (table) in
            table.column(id, primaryKey: true)
            table.column(isPace)
            table.column(name)
            table.column(experimenter)
            table.column(firstInfo)
            table.column(secondInfo)
            table.column(time)
            table.column(dataTime)
            table.column(femNumCOP)
        }
        
        do {
            try self.database.run(createTable)
            print("created masterTable")
        } catch {
            print(error)
        }
    }
    
    // I only use this in testing
    func dropMasterTable() {
        do {
            try database.run(masterTable.drop())
        } catch {
            print(error)
        }
        do {
            for table in experiments {
                try database.run(table.drop())
            }
        } catch {
            print(error)
        }
    }
    
    // adds experiment in master table and creates new test table
    func addExperiment(iP: Bool, nm: String, exp: String, fI: String, sI: String, fn: String) {
        if let ident = getID {
            do {
                try database.run(masterTable.insert(id <- ident, isPace <- iP, name <- nm, experimenter <- exp, firstInfo <- fI, secondInfo <- sI, time <- 0, dataTime <- getTime(), femNumCOP <- fn))
                currID = ident
                print(ident)
                
                let createTable: String
                if iP {
                    createTable = experiments[ident - 1].create { (table) in
                    table.column(id, primaryKey: .autoincrement)
                    table.column(event)
                    table.column(eventType)
                    table.column(time)
                    }
                } else {
                    createTable = experiments[ident - 1].create { (table) in
                    table.column(id, primaryKey: .autoincrement)
                    table.column(event)
                    table.column(time)
                    }
                }
                do {
                    try self.database.run(createTable)
                    print("created experiment\(ident)")
                } catch {
                    print(error)
                }
            } catch {
                print(error)
            }
        } else {
            print("max experiments")
        }
    }
    
    // I only use in testing
    func listExperiments() {
        do {
            let experimentsList = try self.database.prepare(self.masterTable)
            for experiment in experimentsList {
                print("Id: \(experiment[self.id]), isPacd: \(experiment[self.isPace]), name: \(experiment[self.name]), experimenter: \(experiment[self.experimenter]), info one: \(experiment[self.firstInfo]), info two: \(experiment[self.secondInfo])")
            }
        } catch {
            print(error)
        }
    }
    
    func deleteExperiment(ident: Int) {
        do {
            let experiment = masterTable.filter(id == ident)
            try database.run(experiment.delete())
            
            do {
                try database.run(experiments[ident - 1].drop())
            } catch {
                print(error)
            }
            
        } catch {
            print(error)
        }
    }
    
    // returns ids of tests that are currently saved
    func getExperimentIDs() -> [Int] {
        var ids: [Int] = []
        do {
            let experiments = try self.database.prepare(self.masterTable)
            for experiment in experiments {
                ids.append(experiment[id])
            }
        } catch {
            print(error)
        }
        return ids
    }
    
    // pace observations have an event (mount, ears, flag, etc), an event type (0,1,2,3 only valid for mount, intro, and ejac. Other events I give a default value), and time (seconds at which it occurs
    func addPaceObservation(ev: String, evT: Int, tm: Int) {
        do {
            try database.run(experiments[currID - 1].insert(event <- ev, eventType <- evT, time <- tm))
        } catch {
            print(error)
        }
    }
    
    // Same as Pacing observation but no event type
    func addCOPObservation(ev: String, tm: Int) {
        do {
            try database.run(experiments[currID - 1].insert(event <- ev, time <- tm))
        } catch {
            print(error)
        }
    }
    
    // I only use this for testing
    func displayExperimentData(for experiment: Int) -> String {
        var display = ""
        do {
            let lines = try self.database.prepare(experiments[experiment - 1])
            
            if getIsPace(ident: experiment) {
                for line in lines {
                display += ("Id: \(line[self.id]), event: \(line[self.event]), event type: \(line[self.eventType]), time: \(line[self.time]))\r\n")
                }
            } else {
                for line in lines {
                    display += ("Id: \(line[self.id]), event: \(line[self.event]), time: \(line[self.time]))\r\n")
                }
            }
        } catch {
            print(error)
        }
        return display
    }
    
    //Again, these are tests not experiments. She wants them named in this format I think
    func getExperimentName(ident: Int) -> String {
        do {
            let experimentsList = try database.prepare(masterTable)
            for experiment in experimentsList {
                if experiment[self.id] == ident {
                    if getIsPace(ident: ident) {
                        return "Pacing: \(experiment[self.firstInfo]) \(experiment[self.name])"
                    } else {
                        return "COP: \(experiment[self.name])"
                    }
                }
            }
        } catch {
            print(error)
        }
        return "Could Not Find Name!"
    }
    
    func setCurrID(ident: Int) {
        currID = ident
    }
    
    // Master Table saves the time of the test as it happens. That way if something happens and the user has to reload the test, it remembers the time it left off at
    func updateTime(ident: Int, newTime: Int) {
        do {
            let experiment = masterTable.filter(id == ident)
            if try database.run(experiment.update(time <- newTime)) > 0 {
                // do nothinng
            } else {
                print("time not found")
            }
        } catch {
            print("update failed: \(error)")
        }
    }
    
    func getTime(ident: Int) -> Int {
        do {
            let experimentsList = try database.prepare(masterTable)
            for experiment in experimentsList {
                if experiment[self.id] == ident {
                    return experiment[self.time]
                }
            }
        } catch {
            print(error)
        }
        return 0
    }
    
    func getIsPace(ident: Int) -> Bool {
        do {
            let experimentsList = try database.prepare(masterTable)
            for experiment in experimentsList {
                if experiment[self.id] == ident {
                    return experiment[self.isPace]
                }
            }
        } catch {
            print(error)
        }
        return true
    }
    // for Pacing, info one is female number and info two is male number. For COP they are the two objects. COP also remembers the female number in femNumCOP
    func getInfos(ident: Int) -> (infoOne: String, infoTwo: String) {
        do {
            let experimentsList = try database.prepare(masterTable)
            for experiment in experimentsList {
                if experiment[self.id] == ident {
                    return (experiment[self.firstInfo], experiment[self.secondInfo])
                }
            }
        } catch {
            print(error)
        }
        return ("error", "error")
    }
    
    func getfemNum(ident: Int) -> String {
        do {
            let experimentsList = try database.prepare(masterTable)
            for experiment in experimentsList {
                if experiment[self.id] == ident {
                    return experiment[self.femNumCOP]
                }
            }
        } catch {
            print(error)
        }
        return "?"
    }
    
    //Gets name of test for Google drive
    func getCSVName() -> String {
        return getExperimentName(ident: currID)+".csv"
    }
    
    //create csv for experiment. This needs to be implemented still. Probably most important thing and last thing that has to be added before app is usable. I've seen a couple of different formats and I'm not sure which one to use so check with Dr. Meerts to make sure you know what she wants. She doesn't know what all the data is so your going to have to ask her for an excel sheet with the formulas
    //the string returned is the csv. , between values and \n between lines. dog:,,Spots/n1,2,3 would give
    //dog:     spots
    //1    2   3
    func getCSVString() -> String {
        if self.getIsPace(ident: currID) {
            return getPaceCSVString()
        } else {
            return getCOPCSVString()
        }
    }
    
    func getPaceCSVString() -> String {
        var csvText = ""
        do {
            let lines = try self.database.prepare(experiments[currID - 1])
            for line in lines {
                csvText += ",\(line[self.event]),\(line[self.eventType]),\(line[self.time])\n"
            }
        } catch {
            print(error)
        }
        return csvText
    }
    
    func getCOPCSVString() -> String {
        var csvText = "ExpName,Name\nExpTyp,COP\nExperimenter,Name\nDate,Today\nFemale,?\nObjOne Time,0\nObjTwo Time,0\nObjOne Chews,0\nObjTwoChews,0\n\n,event,time\n"
        do {
            let lines = try self.database.prepare(experiments[currID - 1])
            for line in lines {
                csvText += ",\(line[self.event]),\(line[self.time])\n"
            }
        } catch {
            print(error)
        }
        return csvText
    }
    
    // creates edit data instance used for editing data
    func getExperimentData(ident: Int) -> EditData {
        if getIsPace(ident: ident) {
            return getPaceData(ident: ident)
        } else {
            return getCOPData(ident: ident)
        }
    }
    
    func getPaceData(ident: Int) -> EditData {
        var data: [DataRow] = []
        var flags: [Int] = []
        do {
            let lines = try self.database.prepare(experiments[currID - 1])
            for line in lines {
                if line[self.event] == "Flag" {
                    flags.append(line[self.time])
                } else {
                    data.append(DataRow(event: line[self.event], eventType: line[self.eventType], time: line[self.time]))
                }
            }
        } catch {
            print(error)
        }
        return EditData(data: data, flags: flags)
    }
    
    func getCOPData(ident: Int) -> EditData {
        var data: [DataRow] = []
        var flags: [Int] = []
        do {
            let lines = try self.database.prepare(experiments[currID - 1])
            for line in lines {
                if line[self.event] == "Flag" {
                    flags.append(line[self.time])
                } else {
                    data.append(DataRow(event: line[self.event], eventType: 0, time: line[self.time]))
                }
            }
        } catch {
            print(error)
        }
        return EditData(data: data, flags: flags)
    }
    
    // saves data from edit data instance to the database
    func savePaceData(data: EditData) {
        do {
            try database.run(experiments[currID - 1].drop())
        } catch {
            print(error)
        }
        let createTable: String
        createTable = experiments[currID - 1].create { (table) in
            table.column(id, primaryKey: .autoincrement)
            table.column(event)
            table.column(eventType)
            table.column(time)
        }
        do {
            try self.database.run(createTable)
            print("created experiment\(currID)")
        } catch {
            print(error)
        }
        for row in data.data {
            addPaceObservation(ev: row.event, evT: row.eventType, tm: row.time)
        }
        for time in data.flags {
            addPaceObservation(ev: "Flag", evT: 0, tm: time)
        }
    }
    
    func saveCOPData(data: EditData) {
        do {
            try database.run(experiments[currID - 1].drop())
        } catch {
            print(error)
        }
        let createTable: String
        createTable = experiments[currID - 1].create { (table) in
            table.column(id, primaryKey: .autoincrement)
            table.column(event)
            table.column(time)
        }
        do {
            try self.database.run(createTable)
            print("created experiment\(currID)")
        } catch {
            print(error)
        }
        for row in data.data {
            addCOPObservation(ev: row.event, tm: row.time)
        }
        for time in data.flags {
            addCOPObservation(ev: "Flag", tm: time)
        }
    }
    
    // make give actual time
    func getTime() -> String {
        return "today"
    }
}
