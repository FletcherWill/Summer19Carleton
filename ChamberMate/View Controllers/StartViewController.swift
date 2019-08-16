//
//  StartViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/16/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit
import SQLite

class StartViewController: UIViewController {

    let dbm = DatabaseManager()
    
    @IBOutlet weak var newExperimentButton: UIButton!
    
    var canCreateNewExperiment: Bool {
        return dbm.getExperimentIDs().count < 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        dbm.createDB()
        dbm.createMasterTable()
        createNewExperimentDisplay()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createNewExperimentDisplay()
    }
    
    func createNewExperimentDisplay() {
        if canCreateNewExperiment {
            newExperimentButton.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        } else {
            newExperimentButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SetupViewController
        {
            let vc = segue.destination as? SetupViewController
            vc!.dbm = self.dbm
        } else if segue.identifier == "Load Experiment" {
            let vc = segue.destination as? LoadViewController
            vc!.dbm = self.dbm
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Open Setup" {
            return canCreateNewExperiment
        }
        return true
    }

}
