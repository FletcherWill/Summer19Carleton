//
//  COPViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/21/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

//She doesn't care as much about cop. When you are done with pacing, you could make this look nicer and make it so view is updated when user taps and not just after every second. You can probably just call updateviewfrommodel after a click
class COPViewController: UIViewController {

    
    @IBOutlet weak var objectOneButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var objectTwoButton: UIButton!
    @IBOutlet weak var chewButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var toggleTimerButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    let hiddenColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    let shownColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    
    var cop: COP!
    var dbm: DatabaseManager!
    private weak var timer: Timer?
    
    override func viewDidLoad() {
        updateViewFromModel()
        objectOneButton.setTitle(cop.objectOne, for: .normal)
        objectTwoButton.setTitle(cop.objectTwo, for: .normal)
        super.viewDidLoad()
    }
    
    
    @IBAction func toggleTimer(_ sender: UIButton) {
        cop.timerRunning = !cop.timerRunning
        if cop.timerRunning {
            startTimer()
            toggleTimerButton.setTitle("Stop Timer", for: UIControl.State.normal)
        } else {
            stopTimer()
            toggleTimerButton.setTitle("Start Timer", for: UIControl.State.normal)
        }
        updateViewFromModel()
    }
    
    
    @IBAction func enterCenter(_ sender: UIButton) {
        if cop.timerRunning, !cop.inCenter {
            cop.inCenter = true
            dbm.addCOPObservation(ev: "Center", tm: cop.time)
        }
    }
    
    @IBAction func exitCenter(_ sender: UIButton) {
        if cop.timerRunning, cop.inCenter {
            cop.inCenter = false
            dbm.addCOPObservation(ev: sender.currentTitle!, tm: cop.time)
        }
    }
    
    
    @IBAction func addFlag(_ sender: UIButton) {
        dbm.addCOPObservation(ev: "Flag", tm: cop.time)
    }
    
    @IBAction func chew(_ sender: UIButton) {
        if cop.timerRunning {
            dbm.addCOPObservation(ev: "Chew", tm: cop.time)
        }
    }
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.cop.time += 1
            self.dbm.updateTime(ident: self.dbm.currID, newTime: self.cop.time)
            self.updateViewFromModel()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func updateViewFromModel() {
        timeLabel.text = cop.timeToDisplay
        if cop.timerRunning {
            chewButton.backgroundColor = shownColor
            if cop.inCenter {
                centerButton.backgroundColor = hiddenColor
                objectOneButton.backgroundColor = shownColor
                objectTwoButton.backgroundColor = shownColor
            } else {
                centerButton.backgroundColor = shownColor
                objectOneButton.backgroundColor = hiddenColor
                objectTwoButton.backgroundColor = hiddenColor
            }
        } else {
            objectOneButton.backgroundColor = hiddenColor
            objectTwoButton.backgroundColor = hiddenColor
            centerButton.backgroundColor = hiddenColor
            chewButton.backgroundColor = hiddenColor
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Edit COP" {
            let vc = segue.destination as? EditCOPViewController
            vc!.dbm = self.dbm
            vc!.editData = dbm.getCOPData(ident: dbm.currID)
        } else if segue.identifier == "Export Experiment" {
            let vc = segue.destination as? ExportViewController
            vc!.dbm = self.dbm
        }
    }
    
}
