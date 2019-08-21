//
//  EditViewController.swift
//  DrawPractice
//
//  Created by Will Fletcher on 8/5/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

//vc to edit pacing
class EditPaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var meertsTableButton: UIBarButtonItem!
    @IBOutlet weak var flagsCollection: UICollectionView!
    @IBOutlet weak var meertsTableView: UITableView!
    var dbm: DatabaseManager!
    var editData: EditData!
    var selectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        meertsTableView.delegate = self
        meertsTableView.dataSource = self
        flagsCollection.delegate = self
        flagsCollection.dataSource = self
        meertsTableView.rowHeight = 80
        meertsTableView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        meertsTableView.reloadData()
        updateViewFromModel()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editData.data.count
    }
    
    // instruction for creating table view cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = meertsTableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! MeertsTableViewCell
        let eventsWithTypes = ["Mount","Intro","Ejac"]
        cell.eventLabel.text = editData.data[indexPath.row].event
        if eventsWithTypes.contains(editData.data[indexPath.row].event) {
            cell.eventTypeLabel.text = "\(editData.data[indexPath.row].eventType)"
        } else {
            cell.eventTypeLabel.text = ""
        }
        cell.timeLabel.text = "\(editData.data[indexPath.row].time)"
        cell.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.editData.data.remove(at: indexPath.row)
            meertsTableView.deleteRows(at: [indexPath], with: .fade)
        }
        updateViewFromModel()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //allows moving of rows
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let rowToMove = editData.data[sourceIndexPath.row]
        if sourceIndexPath.row <= destinationIndexPath.row {
            editData.data.insert(rowToMove, at: destinationIndexPath.row + 1)
            editData.data.remove(at: sourceIndexPath.row)
        } else {
            editData.data.insert(rowToMove, at: destinationIndexPath.row)
            editData.data.remove(at: sourceIndexPath.row + 1)
        }
        updateViewFromModel()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "Edit Pace Row", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Edit Pace Row" {
            let vc = segue.destination as? EditPaceRowViewController
            vc!.editData = self.editData
            vc!.row = self.selectedRow!
        } else if segue.identifier == "Meerts Table View" {
            let vc = segue.destination as? MeertsViewController
            vc!.editData = self.editData
            vc!.dbm = self.dbm
        }
    }
    
    @IBAction func AddRow(_ sender: UIBarButtonItem) {
        self.editData.data.append(DataRow(event: "Missing", eventType: 0, time: 0))
        meertsTableView.reloadData()
        updateViewFromModel()
    }
    
    @IBAction func toggleEditMode(_ sender: UIBarButtonItem) {
        meertsTableView.isEditing = !meertsTableView.isEditing
    }
    
    private func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
    }
    
    // checks if events are possible (if it is the events are saved. She may want it so data is always saved even if events impossible i.e. not in chronological order or kick occurs while out)
    func dataIsLegal() -> Bool {
        var isIn = false
        var prevTime = 0
        let illegalWhileOut = ["Kick", "Mount", "Intro", "Ejac", "Out"]
        for row in editData.data {
            if row.event == "Missing" {
                return false
            }
            if row.time < prevTime {
                return false
            } else {
                prevTime = row.time
            }
            if isIn {
                if row.event == "In" {
                    return false
                } else if row.event == "Out" {
                    isIn = false
                }
            } else {
                if illegalWhileOut.contains(row.event) {
                    return false
                } else if row.event == "In" {
                    isIn = true
                }
            }
        }
        return true
    }
    
    func updateViewFromModel() {
        if dataIsLegal() {
            meertsTableButton.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.496509254, alpha: 1)
            dbm.savePaceData(data: editData)
        } else {
            meertsTableButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Meerts Table View" {
            return dataIsLegal()
        }
        return true
    }
    
    
    
    
}

extension EditPaceViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.editData.flags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.flagsCollection.dequeueReusableCell(withReuseIdentifier: "flag", for: indexPath)
        if let flagCell = cell as? FlagCollectionViewCell {
            flagCell.flagLabel.text = "\(editData.flags[indexPath.row])"
        }
        return cell
    }
    
    
    //deletes flag from collection view and editdata.flags. Note that change is not saved until a legal ordering of events is reached. She may want less user protection than I provide
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.editData.flags.remove(at: indexPath.row)
        self.flagsCollection.deleteItems(at: [indexPath])
        updateViewFromModel()
    }
    
}
