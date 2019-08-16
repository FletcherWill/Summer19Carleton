//
//  ViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/14/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {
    
    let notSelectableColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    let selectableColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    
    var dbm: DatabaseManager!

    @IBOutlet weak var experimentTitle: UITextField!
    @IBOutlet weak var experimenterName: UITextField!
    @IBOutlet weak var femaleNumber: UITextField!
    @IBOutlet weak var studNumber: UITextField!
    @IBOutlet weak var objectOne: UITextField!
    @IBOutlet weak var objectTwo: UITextField!
    
    @IBOutlet weak var pacingButton: UIButton!
    @IBOutlet weak var copButton: UIButton!
    
    var setup = Setup()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        experimentTitle.delegate = self
        experimenterName.delegate = self
        femaleNumber.delegate = self
        studNumber.delegate = self
        objectOne.delegate = self
        objectTwo.delegate = self
        
        pacingButton.backgroundColor = UIColor.black
        copButton.backgroundColor = UIColor.black
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if var navigationArray = self.navigationController?.viewControllers, navigationArray.count > 2 {
            navigationArray.remove(at: 1)
            self.navigationController?.viewControllers = navigationArray
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        femaleNumber.resignFirstResponder()
        studNumber.resignFirstResponder()
        experimentTitle.resignFirstResponder()
        experimenterName.resignFirstResponder()
        objectOne.resignFirstResponder()
        objectTwo.resignFirstResponder()
        updateViewFromModel()
    }
    
    func updateViewFromModel() {
        setup.updateValues(et: experimentTitle.text, en: experimenterName.text, fn: femaleNumber.text, sn: studNumber.text, oo: objectOne.text, ot: objectTwo.text)
        setup.updateSelectable()
        if setup.pacingSelectable {
            pacingButton.backgroundColor = selectableColor
        } else {
            pacingButton.backgroundColor = notSelectableColor
        }
        if setup.copSelectable {
            copButton.backgroundColor = selectableColor
        } else {
            copButton.backgroundColor = notSelectableColor
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Begin Pace" {
            dbm.addExperiment(iP: true, nm: experimentTitle.text!, exp: experimenterName.text!, fI: femaleNumber.text!, sI: studNumber.text!)
            let vc = segue.destination as? PaceViewController
            vc!.dbm = self.dbm
            vc!.pace = Pace()
        } else if segue.identifier == "Begin COP" {
            dbm.addExperiment(iP: false, nm: experimentTitle.text!, exp: experimenterName.text!, fI: objectOne.text!, sI: objectTwo.text!)
            let vc = segue.destination as? COPViewController
            vc!.dbm = self.dbm
            vc!.cop = COP(objOne: objectOne.text!, objTwo: objectTwo.text!)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Begin Pace" {
            return setup.pacingSelectable
        } else if identifier == "Begin COP" {
            return setup.copSelectable
        }
        return false
    }
    
    
}

extension SetupViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateViewFromModel()
        textField.resignFirstResponder()
        return true
    }
    
}
