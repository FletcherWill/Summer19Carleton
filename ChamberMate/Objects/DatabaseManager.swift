//
//  DatabaseManager.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/16/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import Foundation
import SQLite

class DatabaseManager {

    var database: Connection!
    var currID = 0
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
    
    let experiments = [Table("experiment1"), Table("experiment2"),Table("experiment3"),Table("experiment4"),Table("experiment5")]
    
    let event =  Expression<String>("event")
    let eventType = Expression<Int>("eventType")
    let time = Expression<Int>("time")
    
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
        }
        
        do {
            try self.database.run(createTable)
            print("created masterTable")
        } catch {
            print(error)
        }
    }
    
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
    
    func addExperiment(iP: Bool, nm: String, exp: String, fI: String, sI: String) {
        if let ident = getID {
            do {
                try database.run(masterTable.insert(id <- ident, isPace <- iP, name <- nm, experimenter <- exp, firstInfo <- fI, secondInfo <- sI, time <- 0))
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
    
    func addPaceObservation(ev: String, evT: Int, tm: Int) {
        do {
            try database.run(experiments[currID - 1].insert(event <- ev, eventType <- evT, time <- tm))
        } catch {
            print(error)
        }
    }
    
    func addCOPObservation(ev: String, tm: Int) {
        do {
            try database.run(experiments[currID - 1].insert(event <- ev, time <- tm))
        } catch {
            print(error)
        }
    }
    
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
    
    func getCSVName() -> String {
        return getExperimentName(ident: currID)+".csv"
    }
    
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
}
