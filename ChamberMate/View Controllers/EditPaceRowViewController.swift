//
//  EditPaceRowViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 8/7/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

//vc for editing Pacing event list 
class EditPaceRowViewController: UIViewController {
    
    @IBOutlet weak var eventPicker: UIPickerView!
    var selectedEvent: String?
    let events = ["In","Out","Mount", "Intro", "Ejac", "Hops", "Ears", "Roll", "Squeak", "Kick"]
    
    @IBOutlet weak var eventTypePicker: UIPickerView!
    var selectedEventType: String?
    let eventTypes = ["0","1","2","3"]
    
    @IBOutlet weak var timeTextField: UITextField!
    
    
    var editData: EditData!
    var row: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeTextField.delegate = self
        timeTextField.text = "\(editData.data[row].time)"
        eventPicker.delegate = self
        eventPicker.dataSource = self
        eventTypePicker.delegate = self
        eventTypePicker.dataSource = self
        eventPicker.selectRow(events.firstIndex(of: editData.data[row].event) ??  0, inComponent: 0, animated: false)
        eventTypePicker.selectRow(eventTypes.firstIndex(of: "\(editData.data[row].eventType)") ??  0, inComponent: 0, animated: false)
        // Do any additional setup after loading the view.
    }

}

extension EditPaceRowViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.eventPicker {
            return events.count
        } else {return eventTypes.count}
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.eventPicker {
            return events[row]
        } else {return eventTypes[row]}
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == eventPicker {
            selectedEvent = events[row]
            self.editData.data[self.row].event = events[row]
        } else if pickerView == eventTypePicker {
            selectedEventType = eventTypes[row]
            self.editData.data[self.row].eventType = Int(eventTypes[row])!
        }
    }
    
    
}

extension EditPaceRowViewController: UITextFieldDelegate {
    
    // occurs when user presses return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let time = Int(textField.text!) {
            editData.data[row].time = time
        }
        return true
    }
    
    //when user selcets screen off keyboard. right now just dismisses keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timeTextField.resignFirstResponder()
    }
    
}
