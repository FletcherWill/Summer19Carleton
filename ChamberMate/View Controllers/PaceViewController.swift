//
//  PaceViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/15/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

class PaceViewController: UIViewController {
    
    @IBOutlet var mountButtons: [UIButton]!
    @IBOutlet var introButtons: [UIButton]!
    @IBOutlet var ejacButtons: [UIButton]!
    
    @IBOutlet weak var inButton: UIButton!
    @IBOutlet weak var outButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var timeDisplay: UILabel!
    @IBOutlet weak var timerController: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    
    
    @IBOutlet weak var hopsButton: UIButton!
    @IBOutlet weak var earsButton: UIButton!
    @IBOutlet weak var squeakButton: UIButton!
    @IBOutlet weak var rollButton: UIButton!
    @IBOutlet weak var kickButton: UIButton!
    
    let hiddenColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    let shownColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    
    var pace: Pace!
    var dbm: DatabaseManager!
    private weak var timer: Timer?
    
    
    @IBOutlet weak var mountLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var ejacLabel: UILabel!
    
    var mountCount = 0 {
        didSet {
            mountLabel.text = "Mount: \(mountCount)"
        }
    }
    var introCount = 0 {
        didSet {
            introLabel.text = "Intro: \(introCount)"
        }
    }
    var ejacCount = 0 {
        didSet {
            ejacLabel.text = "Ejac: \(ejacCount)"
        }
    }
    
    
    override func viewDidLoad() {
        buttonsShown(shown: false)
        updateViewFromModel()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pace.isIn = false
        pace.timerRunning = false
        updateViewFromModel()
        timerController.setTitle("Start Timer", for: UIControl.State.normal)
        setCounts()
    }
    
    @IBAction func toggleTimer(_ sender: UIButton) {
        pace.timerRunning = !pace.timerRunning
        if pace.timerRunning {
            startTimer()
            timerController.setTitle("Stop Timer", for: UIControl.State.normal)
        } else {
            stopTimer()
            timerController.setTitle("Start Timer", for: UIControl.State.normal)
        }
        updateViewFromModel()
    }
    
    
    @IBAction func toggleInOut(_ sender: UIButton) {
        if sender.backgroundColor == shownColor {
            if pace.timerRunning {
                let event: String
                if pace.isIn {
                    event = "Out"
                } else {
                    event = "In"
                }
                dbm.addPaceObservation(ev: event, evT: 0, tm: pace.time)
                pace.isIn = !pace.isIn
            }
            updateViewFromModel()
            resetButtonColors()
        }
    }
    
    @IBAction func addFlag(_ sender: UIButton) {
        dbm.addPaceObservation(ev: "Flag", evT: 0, tm: self.pace.time)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.pace.time += 1
            self.dbm.updateTime(ident: self.dbm.currID, newTime: self.pace.time)
            self.updateViewFromModel()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func updateViewFromModel() {
        timeDisplay.text = pace.timeToDisplay
        buttonsShown(shown: pace.showButtons)
        behaviorsShown()
        updateInOutButton()
    }
    
    func setCounts() {
        var mount = 0
        var intro = 0
        var ejac = 0
        for row in dbm.getExperimentData(ident: dbm.currID).data {
            if row.event == "Mount" {
                mount += 1
            } else if row.event == "Intro" {
                intro += 1
            } else if row.event == "Ejac" {
                ejac += 1
            }
        }
        mountCount = mount
        introCount = intro
        ejacCount = ejac
    }
    
    func buttonsShown(shown: Bool) {
        for index in mountButtons.indices {
            if shown {
                if mountButtons[index].backgroundColor == hiddenColor {
                    mountButtons[index].backgroundColor = shownColor
                    mountButtons[index].setTitle("\(index)", for: UIControl.State.normal)
                    introButtons[index].backgroundColor = shownColor
                    introButtons[index].setTitle("\(index)", for: UIControl.State.normal)
                    ejacButtons[index].backgroundColor = shownColor
                    ejacButtons[index].setTitle("\(index)", for: UIControl.State.normal)
                }
            } else {
                mountButtons[index].backgroundColor = hiddenColor
                introButtons[index].backgroundColor = hiddenColor
                ejacButtons[index].backgroundColor = hiddenColor
            }
        }
    }
    
    func behaviorsShown() {
        if pace.timerRunning {
            if earsButton.backgroundColor == hiddenColor {
                earsButton.backgroundColor = shownColor
                hopsButton.backgroundColor = shownColor
                squeakButton.backgroundColor = shownColor
                rollButton.backgroundColor = shownColor
                kickButton.backgroundColor = shownColor
                if !pace.isIn {
                    kickButton.backgroundColor = hiddenColor
                }
            }
        }
        else {
            earsButton.backgroundColor = hiddenColor
            hopsButton.backgroundColor = hiddenColor
            squeakButton.backgroundColor = hiddenColor
            rollButton.backgroundColor = hiddenColor
            kickButton.backgroundColor = hiddenColor
        }
    }
    
    func updateInOutButton() {
        if !pace.timerRunning {
            inButton.backgroundColor = hiddenColor
            outButton.backgroundColor = hiddenColor
        } else{
            inButton.backgroundColor = shownColor
            if pace.isIn {
                inButton.backgroundColor = hiddenColor
                outButton.backgroundColor = shownColor
            } else {
                inButton.backgroundColor = shownColor
                outButton.backgroundColor = hiddenColor
            }

        }
    }
    
    
    @IBAction func addObservation(_ sender: UIButton) {
        if pace.showButtons {
            let event: String
            let typ: Int
            if mountButtons.contains(sender) {
                event = "Mount"
                typ = mountButtons.firstIndex(of: sender)!
                mountCount  += 1
            } else if introButtons.contains(sender) {
                event = "Intro"
                typ = introButtons.firstIndex(of: sender)!
                introCount += 1
            } else if ejacButtons.contains(sender) {
                event = "Ejac"
                typ = ejacButtons.firstIndex(of: sender)!
                ejacCount += 1
            } else {
                event = "Missing"
                typ = -1
            }
            dbm.addPaceObservation(ev: event, evT: typ, tm: pace.time)
            resetButtonColors()
            sender.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
    }
    
    func resetButtonColors() {
        if pace.isIn {
            for button in mountButtons {
                button.backgroundColor = shownColor
            }
            for button in introButtons {
                button.backgroundColor = shownColor
            }
            for button in ejacButtons {
                button.backgroundColor = shownColor
            }
        }
        earsButton.backgroundColor = shownColor
        hopsButton.backgroundColor = shownColor
        squeakButton.backgroundColor = shownColor
        rollButton.backgroundColor = shownColor
        kickButton.backgroundColor = shownColor
        if !pace.isIn {
            kickButton.backgroundColor = hiddenColor
        }
    }
    
    
    @IBAction func addHops(_ sender: UIButton) {
        if sender.backgroundColor == shownColor || sender.backgroundColor == #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1) {
            dbm.addPaceObservation(ev: "Hops", evT: 0, tm: pace.time)
            resetButtonColors()
            sender.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
    }
    
    
    @IBAction func addEars(_ sender: UIButton) {
        if sender.backgroundColor == shownColor || sender.backgroundColor == #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1) {
            dbm.addPaceObservation(ev: "Ears", evT: 0, tm: pace.time)
            resetButtonColors()
            sender.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
    }
    
    @IBAction func addSqueak(_ sender: UIButton) {
        if sender.backgroundColor == shownColor || sender.backgroundColor == #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1) {
            dbm.addPaceObservation(ev: "Squeak", evT: 0, tm: pace.time)
            resetButtonColors()
            sender.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
    }
    
    @IBAction func addRoll(_ sender: UIButton) {
        if sender.backgroundColor == shownColor || sender.backgroundColor == #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1) {
            dbm.addPaceObservation(ev: "Roll", evT: 0, tm: pace.time)
            resetButtonColors()
            sender.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
    }
    
    @IBAction func addKick(_ sender: UIButton) {
        if sender.backgroundColor == shownColor || sender.backgroundColor == #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1) {
            dbm.addPaceObservation(ev: "Kick", evT: 0, tm: pace.time)
            resetButtonColors()
            sender.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Edit Pacing" {
            let vc = segue.destination as? EditPaceViewController
            vc!.dbm = self.dbm
            vc!.editData = self.dbm.getExperimentData(ident: self.dbm.currID)
        } else if segue.identifier == "Export Experiment" {
            let vc = segue.destination as? ExportViewController
            vc!.dbm = self.dbm
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
    }
    
}
