//
//  EditCOPRowViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 8/15/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

// edit cop row. see pacing counterpart if necesary
class EditCOPRowViewController: UIViewController {

    @IBOutlet weak var eventPicker: UIPickerView!
    var selectedEvent: String?
    var events: [String] = []
    @IBOutlet weak var timeTextField: UITextField!
    
    var editData: EditData!
    var row: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventPicker.delegate = self
        eventPicker.dataSource = self
        eventPicker.selectRow(events.firstIndex(of: editData.data[row].event) ?? 0, inComponent: 0, animated: false)
        
        timeTextField.delegate = self
        timeTextField.text = "\(editData.data[row].time)"

        // Do any additional setup after loading the view.
    }
    


}


extension EditCOPRowViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.events.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return events[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedEvent = events[row]
        self.editData.data[self.row].event = events[row]
        
    }
    
    
}

extension EditCOPRowViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let time = Int(textField.text!) {
            editData.data[row].time = time
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timeTextField.resignFirstResponder()
    }
    
}
