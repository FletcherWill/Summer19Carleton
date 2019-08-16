//
//  LoadViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/19/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController {

    var dbm: DatabaseManager!
    
    @IBOutlet var experimentButtons: [UIButton]!
    @IBOutlet var deleteButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayButtons()
        // Do any additional setup after loading the view.
    }
    
    func displayButtons() {
        let currExperiments = dbm.getExperimentIDs()
        for val in 1...5 {
            if currExperiments.contains(val) {
                experimentButtons[val - 1].backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
                deleteButtons[val - 1].backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.496509254, alpha: 1)
                experimentButtons[val - 1].setTitle(dbm.getExperimentName(ident: val), for: UIControl.State.normal)
            } else {
                experimentButtons[val - 1].backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                deleteButtons[val - 1].backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
    }
    
    
    @IBAction func deleteExperiment(_ sender: UIButton) {
        if let experimentIndex = deleteButtons.firstIndex(of: sender), dbm.getExperimentIDs().contains(experimentIndex + 1) {
            dbm.deleteExperiment(ident: experimentIndex + 1)
        }
        displayButtons()
    }
    @IBAction func loadExperiment(_ sender: UIButton) {
        let id = experimentButtons.firstIndex(of: sender)! + 1
        if dbm.getExperimentIDs().contains(id) {
            dbm.setCurrID(ident: id)
            if dbm.getIsPace(ident: id) {
                self.performSegue(withIdentifier: "Load Pace", sender: nil)
            } else {
                self.performSegue(withIdentifier: "Load COP", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Load Pace" {
            let vc = segue.destination as? PaceViewController
            vc!.dbm = self.dbm
            vc!.pace = Pace(time: self.dbm.getTime(ident: dbm.currID))
        } else if segue.identifier == "Load COP" {
            let vc = segue.destination as? COPViewController
            vc!.dbm = self.dbm
            vc!.cop = COP(time: self.dbm.getTime(ident: dbm.currID), objOne: dbm.getInfos(ident: dbm.currID).infoOne, objTwo: dbm.getInfos(ident: dbm.currID).infoTwo)
        }
    }
}
