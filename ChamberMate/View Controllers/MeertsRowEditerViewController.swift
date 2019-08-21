//
//  MeertsRowEditerViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 8/14/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

// vc for meerts table edit screen
class MeertsRowEditerViewController: UIViewController {
    
    @IBOutlet weak var inTextFeild: UITextField!
    @IBOutlet weak var outTextField: UITextField!
    @IBOutlet weak var mountTextField: UITextField!
    @IBOutlet weak var mountPicker: UIPickerView!
    @IBOutlet weak var introTextField: UITextField!
    @IBOutlet weak var introPicker: UIPickerView!
    @IBOutlet weak var ejacTextField: UITextField!
    @IBOutlet weak var ejacPicker: UIPickerView!
    
    var editData: EditData!
    var row: Int!
    var meertsData: [[Int?]]!
    
    let eventTypes = ["0","1","2","3","None"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        inTextFeild.delegate = self
        outTextField.delegate = self
        mountTextField.delegate = self
        introTextField.delegate = self
        ejacTextField.delegate = self
        
        mountPicker.delegate = self
        mountPicker.dataSource = self
        introPicker.delegate = self
        introPicker.dataSource = self
        ejacPicker.delegate = self
        ejacPicker.dataSource = self
        
        mountPicker.selectRow(self.eventTypes.firstIndex(of: "\(self.meertsData[row][3] ?? 4)") ?? 4, inComponent: 0, animated: false)
        introPicker.selectRow(self.eventTypes.firstIndex(of: "\(self.meertsData[row][5] ?? 4)") ?? 4, inComponent: 0, animated: false)
        ejacPicker.selectRow(self.eventTypes.firstIndex(of: "\(self.meertsData[row][7] ?? 4)") ?? 4, inComponent: 0, animated: false)
        
        if let time = meertsData[row][0] {
            inTextFeild.text = "\(time)"
        }
        if let time = meertsData[row][1] {
            outTextField.text = "\(time)"
        }
        if let time = meertsData[row][2] {
            mountTextField.text = "\(time)"
        }
        if let time = meertsData[row][4] {
            introTextField.text = "\(time)"
        }
        if let time = meertsData[row][6] {
            ejacTextField.text = "\(time)"
        }
        // Do any additional setup after loading the view.
    }
    
    //gets index of editdata.data where a time would should be inserted. if inserting 3 into 1,3,3,4 would return 1
    func getInsertIndexOf(time: Int) -> Int{
        var insertIndex = 0
        for event in editData.data {
            if event.time < time {
                insertIndex += 1
            } else { return insertIndex}
        }
        return insertIndex
    }
    
    //return index of event if it exists or nil
    func getIndexOfRowWith(Event: String, EventType: Int, time: Int) -> Int? {
        var index = 0
        for row in editData.data {
            if row.event == Event, row.eventType == EventType, row.time == time {
                return index
            } else { index += 1 }
        }
        return nil
    }
    

}

extension MeertsRowEditerViewController: UITextFieldDelegate {
    
    //note that if user doesn't press return (just taps screen off keyboard) nothing is saved. You should probably change this
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // if entered value is not an int do nothing. otherwise updatae meertsdata and editdata.data
        if let time = Int(textField.text!) {
            if textField == inTextFeild {
                if meertsData[row][0] == nil {
                    meertsData[row][0] = time
                    editData.data.insert(DataRow(event: "In", eventType: 0, time: time), at: self.getInsertIndexOf(time: time))
                } else {
                    editData.data[getIndexOfRowWith(Event: "In", EventType: 0, time: meertsData[row][0]!)!].time = time
                    meertsData[row][0] = time
                }
            } else if textField == outTextField {
                if meertsData[row][1] == nil {
                    meertsData[row][1] = time
                    editData.data.insert(DataRow(event: "Out", eventType: 0, time: time), at: self.getInsertIndexOf(time: time))
                } else {
                    editData.data[getIndexOfRowWith(Event: "Out", EventType: 0, time: meertsData[row][1]!)!].time = time
                    meertsData[row][1] = time
                }
            } else if textField == mountTextField {
                if meertsData[row][2] == nil {
                    meertsData[row][2] = time
                    meertsData[row][3] = 0
                    editData.data.insert(DataRow(event: "Mount", eventType: 0, time: time), at: self.getInsertIndexOf(time: time))
                    mountPicker.selectRow(0, inComponent: 0, animated: true)
                } else {
                    editData.data[getIndexOfRowWith(Event: "Mount", EventType: meertsData[row][3]!, time: meertsData[row][2]!)!].time = time
                    meertsData[row][2] = time
                }
            } else if textField == introTextField {
                if meertsData[row][4] == nil {
                    meertsData[row][4] = time
                    meertsData[row][5] = 0
                    editData.data.insert(DataRow(event: "Intro", eventType: 0, time: time), at: self.getInsertIndexOf(time: time))
                    introPicker.selectRow(0, inComponent: 0, animated: true)
                } else {
                    editData.data[getIndexOfRowWith(Event: "Intro", EventType: meertsData[row][5]!, time: meertsData[row][4]!)!].time = time
                    meertsData[row][4] = time
                }
            } else {
                if meertsData[row][6] == nil {
                    meertsData[row][6] = time
                    meertsData[row][7] = 0
                    editData.data.insert(DataRow(event: "Ejac", eventType: 0, time: time), at: self.getInsertIndexOf(time: time))
                    ejacPicker.selectRow(0, inComponent: 0, animated: true)
                } else {
                    editData.data[getIndexOfRowWith(Event: "Ejac", EventType: meertsData[row][7]!, time: meertsData[row][6]!)!].time = time
                    meertsData[row][6] = time
                }
            }
        } else if textField.text == "" || textField.text == nil {
            if textField == inTextFeild {
                if meertsData[row][0] != nil  {
                    editData.data.remove(at: getIndexOfRowWith(Event: "In", EventType: 0, time: meertsData[row][0]!)!)
                    meertsData[row][0] = nil
                }
            } else if textField == outTextField {
                if meertsData[row][1] != nil  {
                    editData.data.remove(at: getIndexOfRowWith(Event: "Out", EventType: 0, time: meertsData[row][1]!)!)
                    meertsData[row][1] = nil
                }
            } else if textField == mountTextField {
                if meertsData[row][2] != nil  {
                    editData.data.remove(at: getIndexOfRowWith(Event: "Mount", EventType: meertsData[row][3]!, time: meertsData[row][2]!)!)
                    meertsData[row][2] = nil
                    meertsData[row][3] = nil
                    mountPicker.selectRow(4, inComponent: 0, animated: true)
                }
            } else if textField == introTextField {
                if meertsData[row][4] != nil  {
                    editData.data.remove(at: getIndexOfRowWith(Event: "Intro", EventType: meertsData[row][5]!, time: meertsData[row][4]!)!)
                    meertsData[row][4] = nil
                    meertsData[row][5] = nil
                    introPicker.selectRow(4, inComponent: 0, animated: true)
                }
            } else {
                if meertsData[row][6] != nil  {
                    editData.data.remove(at: getIndexOfRowWith(Event: "Ejac", EventType: meertsData[row][7]!, time: meertsData[row][6]!)!)
                    meertsData[row][6] = nil
                    meertsData[row][7] = nil
                    introPicker.selectRow(4, inComponent: 0, animated: true)
                }
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        inTextFeild.resignFirstResponder()
        outTextField.resignFirstResponder()
        mountTextField.resignFirstResponder()
        introTextField.resignFirstResponder()
        ejacTextField.resignFirstResponder()
    }
    
}

extension MeertsRowEditerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eventTypes[row]
    }
    
    //for choosing event type. If no event yet, won't let user move from none, if there is event, user cant select none.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == mountPicker {
            if meertsData[self.row][2] != nil {
                if row != 4 {
                    editData.data[getIndexOfRowWith(Event: "Mount", EventType: meertsData[self.row][3]!, time: meertsData[self.row][2]!)!].eventType = row
                    meertsData[self.row][3] = row
                } else {
                    mountPicker.selectRow(meertsData[self.row][3]!, inComponent: 0, animated: true)
                }
            } else {
                mountPicker.selectRow(4, inComponent: 0, animated: true)
            }
        } else if pickerView == introPicker {
            if meertsData[self.row][4] != nil {
                if row != 4 {
                    editData.data[getIndexOfRowWith(Event: "Intro", EventType: meertsData[self.row][5]!, time: meertsData[self.row][4]!)!].eventType = row
                    meertsData[self.row][5] = row
                } else {
                    introPicker.selectRow(meertsData[self.row][5]!, inComponent: 0, animated: true)
                }
            } else {
                introPicker.selectRow(4, inComponent: 0, animated: true)
            }
        } else {
            if meertsData[self.row][6] != nil {
                if row != 4 {
                    editData.data[getIndexOfRowWith(Event: "Ejac", EventType: meertsData[self.row][7]!, time: meertsData[self.row][6]!)!].eventType = row
                    meertsData[self.row][7] = row
                } else {
                    ejacPicker.selectRow(meertsData[self.row][7]!, inComponent: 0, animated: true)
                }
            } else {
                ejacPicker.selectRow(4, inComponent: 0, animated: true)
            }
        }
    }
    
    
}
