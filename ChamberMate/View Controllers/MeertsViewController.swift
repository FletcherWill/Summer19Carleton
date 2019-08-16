//
//  MeertsViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 8/13/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit

class MeertsViewController: UIViewController {
    
    var dbm: DatabaseManager!
    var editData: EditData!
    var meertsData: [[Int?]] = []
    var selectedRow: Int?

    @IBOutlet weak var meertsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        meertsTable.delegate = self
        meertsTable.dataSource = self
        meertsTable.rowHeight = 80
        meertsTable.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadMeertsData()
        meertsTable.reloadData()
    }
    
    func loadMeertsData(){
        meertsData = []
        let indices = ["In","Out","Mount","MountLQ","Intro","IntroLQ","Ejac","EjacLQ"]
        var row: [Int?] = [nil, nil, nil, nil, nil, nil, nil, nil]
        for item in editData.data {
            if let index = indices.firstIndex(of: item.event) {
                if row[index] == nil {
                    row[index] = item.time
                    if index > 1 {
                        row[index + 1] = item.eventType
                    }
                } else {
                    meertsData.append(row)
                    row = [nil, nil, nil, nil, nil, nil, nil, nil]
                    row[index] = item.time
                    if index > 1 {
                        row[index + 1] = item.eventType
                    }
                }
            }
        }
        if row != [nil, nil, nil, nil, nil, nil, nil, nil] {
            meertsData.append(row)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Edit Meerts Row" {
            let vc = segue.destination as? MeertsRowEditerViewController
            vc!.editData = self.editData
            vc!.row = self.selectedRow!
            vc!.meertsData = self.meertsData
        }
    }
    
    @IBAction func addRow(_ sender: Any) {
        meertsData.append([nil, nil, nil, nil, nil, nil, nil, nil])
        meertsTable.reloadData()
    }
    

}


extension MeertsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meertsData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "Edit Meerts Row", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = meertsTable.dequeueReusableCell(withIdentifier: "MeertsDataCell", for: indexPath) as! MeertsCell
        if let val = meertsData[indexPath.row][0] {
            cell.InLabel.text = "\(val)"
        } else {
            cell.InLabel.text = ""
        }
        if let val = meertsData[indexPath.row][1] {
            cell.outLabel.text = "\(val)"
        } else {
            cell.outLabel.text = ""
        }
        if let val = meertsData[indexPath.row][2] {
            cell.mountLabel.text = "\(val)"
        } else {
            cell.mountLabel.text = ""
        }
        if let val = meertsData[indexPath.row][3] {
            cell.mountLQLabel.text = "\(val)"
        } else {
            cell.mountLQLabel.text = ""
        }
        if let val = meertsData[indexPath.row][4] {
            cell.introLabel.text = "\(val)"
        } else {
            cell.introLabel.text = ""
        }
        if let val = meertsData[indexPath.row][5] {
            cell.introLQLabel.text = "\(val)"
        } else {
            cell.introLQLabel.text = ""
        }
        if let val = meertsData[indexPath.row][6] {
            cell.ejacLabel.text = "\(val)"
        } else {
            cell.ejacLabel.text = ""
        }
        if let val = meertsData[indexPath.row][7] {
            cell.ejacLQLabel.text = "\(val)"
        } else {
            cell.ejacLQLabel.text = ""
        }
        cell.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        
        return cell
    }
    
    
}
