//
//  TesterViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/17/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

// I have used this for testing from time to time. feel free to delete
class TesterViewController: UIViewController {

    let dbm = DatabaseManager()
    
    @IBAction func createDatabase(_ sender: UIButton) {
        dbm.createDB()
    }
    
    @IBAction func createMaster(_ sender: UIButton) {
        dbm.createMasterTable()
    }


    @IBAction func addExperiment(_ sender: UIButton) {
        dbm.addExperiment(iP: true, nm: "experiment", exp: "bob", fI: "1", sI: "2", fn: "3")
    }
    
    @IBAction func listExperiments(_ sender: UIButton) {
        dbm.listExperiments()
    }
    
    @IBAction func dropMaster(_ sender: Any) {
        dbm.dropMasterTable()
    }
    
    @IBAction func deleteExperiment(_ sender: UIButton) {
        let val = dbm.getExperimentIDs().min()
        if val != nil {
            dbm.deleteExperiment(ident: val!)
        }
    }
    
    @IBAction func getIDs(_ sender: UIButton) {
        print(dbm.getExperimentIDs())
    }
    
    @IBAction func addObservation(_ sender: UIButton) {
        dbm.addPaceObservation(ev: "observation", evT: 1, tm: 2)
    }
    
    @IBAction func viewExperiment(_ sender: UIButton) {
        print(dbm.displayExperimentData(for: dbm.currID))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
}
