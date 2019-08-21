//
//  StartViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/16/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit
import SQLite

//This is the first view the user sees. Everything is wrapped in a navigation controller.
//I will try to add comments that I think I would find useful. Feel free to ignore them or to email me if you are confused by something. I was rushed making this so there are some things that are named or organized poorly. I appoligize for this and you may want to fix it
class StartViewController: UIViewController {

    //create instance of dbm that is passed around (by pointer because is a class) by view controllers (vcs)
    let dbm = DatabaseManager()
    
    @IBOutlet weak var newExperimentButton: UIButton!
    
    //if 5 experiments exist have to delete one before creating another
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
    
    //called when view is about to appear (even when previous views are popped from navigaion queue to expose it)
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
    
    

    //give instruction for segue
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
    
    //decides whether segue can occur
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Open Setup" {
            return canCreateNewExperiment
        }
        return true
    }

}
