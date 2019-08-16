//
//  EditPacingViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/19/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

class EditCOPViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var savedButton: UIBarButtonItem!
    
    var dbm: DatabaseManager!
    var editData: EditData!
    var selectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        tableView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        updateViewFromModel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Edit COP Row" {
            let vc = segue.destination as? EditCOPRowViewController
            vc!.editData = self.editData
            vc!.row = self.selectedRow!
            vc!.events = ["Center", "Chew", dbm.getInfos(ident: dbm.currID).infoOne, dbm.getInfos(ident: dbm.currID).infoTwo]
        }
    }
    
    func updateViewFromModel() {
        if dataIsLegal() {
            savedButton.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.496509254, alpha: 1)
            dbm.saveCOPData(data: editData)
        } else {
            savedButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    
    @IBAction func toggleEdit(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
    }
    
    @IBAction func addRow(_ sender: UIBarButtonItem) {
        self.editData.data.append(DataRow(event: "Missing", eventType: 0, time: 0))
        tableView.reloadData()
        updateViewFromModel()
    }
    
    func dataIsLegal() -> Bool {
        var inCenter = true
        var prevTime = 0
        for row in editData.data {
            if row.event == "Missing" {
                return false
            }
            if row.time < prevTime {
                return false
            } else {
                prevTime = row.time
            }
            if inCenter {
                if row.event == "Center" {
                    return false
                } else if row.event != "Chew" {
                    inCenter = false
                }
            } else {
                if row.event == "Center" {
                    inCenter = true
                } else if row.event != "Chew" {
                    return false
                }
            }
        }
        return true
    }
    
    
}

extension EditCOPViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editData.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "COPCell", for: indexPath) as! COPTableViewCell
        cell.eventLabel.text = editData.data[indexPath.row].event
        cell.timeLabel.text = "\(editData.data[indexPath.row].time)"
        cell.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.editData.data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        updateViewFromModel()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
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
        performSegue(withIdentifier: "Edit COP Row", sender: nil)
    }
    
}

extension EditCOPViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.editData.flags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "flag", for: indexPath)
        if let flagCell = cell as? FlagCollectionViewCell {
            flagCell.flagLabel.text = "\(editData.flags[indexPath.row])"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.editData.flags.remove(at: indexPath.row)
        self.collectionView.deleteItems(at: [indexPath])
        updateViewFromModel()
    }
    
}
