//
//  ExportViewController.swift
//  ChamberMate
//
//  Created by Will Fletcher on 7/22/19.
//  Copyright © 2019 Will Fletcher. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

//export experiment to google drive
//more info can be found from google
class ExportViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    var dbm: DatabaseManager!
    let googleDriveService = GTLRDriveService()
    var googleUser: GIDGoogleUser?
    var uploadFolderID: String?
    private weak var timer: Timer?
    
    @IBOutlet weak var folderNameTextField: UITextField!
    var folderName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        folderNameTextField.delegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signInSilently()
        GIDSignIn.sharedInstance()?.scopes = [kGTLRAuthScopeDrive]
        updatView()
    }
    
    
    @IBAction func signInOut(_ sender: UIButton) {
        if googleUser == nil {
            GIDSignIn.sharedInstance()?.signIn()
        } else {
            GIDSignIn.sharedInstance()?.signOut()
            googleUser = nil
        }
        updatView()
    }
    
    @IBAction func uploadExperiment(_ sender: UIButton) {
        // can't upload if noone signed inn
        if googleUser != nil {
            // if no name entered default to "Chambermate Data"
            let folder = folderName ?? "ChamberMate Data"
            self.populateFolderID(fileName: folder)
            // keeps trying to upload until succesful every three seconds. You should probably make it stop after certain point and say can't connect
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
                self.populateFolderID(fileName: folder)
                print(self.uploadFolderID ?? "None")
                if self.uploadFolderID != nil {
                    self.timer!.invalidate()
                    self.uploadFile(name: self.dbm.getCSVName(), folderID: self.uploadFolderID!, fileURL: self.createURL(), service: self.googleDriveService)
                }
            }
        }
    }
    
    //if authenicator stops working you'll have to do some googling and check bridging header
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // A nil error indicates a successful login
        if error == nil {
            self.googleDriveService.authorizer = user.authentication.fetcherAuthorizer()
            self.googleUser = user
        } else {
            self.googleDriveService.authorizer = nil
            self.googleUser = nil
        }
        updatView()
    }
    
    func updatView() {
        if googleUser != nil {
            googleButton.setTitle("Sign Out: \(googleUser!.profile.givenName ?? "NA")", for: .normal)
            uploadButton.backgroundColor = UIColor.lightGray
        } else {
            googleButton.setTitle("Google Sign In", for: .normal)
            uploadButton.backgroundColor = UIColor.black
        }
    }
    
    func createFolder(name: String, service: GTLRDriveService, completion: @escaping (String) -> Void) {
        
        let folder = GTLRDrive_File()
        folder.mimeType = "application/vnd.google-apps.folder"
        folder.name = name
        
        // Google Drive folders are files with a special MIME-type.
        let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        
        self.googleDriveService.executeQuery(query) { (_, file, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            let folder = file as! GTLRDrive_File
            completion(folder.identifier!)
        }
    }
    
    //gets id of folder with given name if it exists.
    func getFolderID(name: String, service: GTLRDriveService, user: GIDGoogleUser, completion: @escaping (String?) -> Void) {
        
        let query = GTLRDriveQuery_FilesList.query()
        
        // Comma-separated list of areas the search applies to. E.g., appDataFolder, photos, drive.
        query.spaces = "drive"
        
        // Comma-separated list of access levels to search in. Some possible values are "user,allTeamDrives" or "user"
        query.corpora = "user"
        
        let withName = "name = '\(name)'" // Case insensitive!
        let foldersOnly = "mimeType = 'application/vnd.google-apps.folder'"
        let ownedByUser = "'\(user.profile!.email!)' in owners"
        query.q = "\(withName) and \(foldersOnly) and \(ownedByUser)"
        
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            let folderList = result as! GTLRDrive_FileList
            self.uploadFolderID = folderList.files?.first?.identifier
            
            // For brevity, assumes only one folder is returned.
            completion(folderList.files?.first?.identifier)
            self.uploadFolderID = folderList.files?.first?.identifier
        }
    }
    
    func populateFolderID(fileName: String) {
        let myFolderName = fileName
        getFolderID(name: myFolderName, service: googleDriveService, user: googleUser!) { folderID in
                if folderID == nil {
                    self.createFolder(
                        name: myFolderName,
                        service: self.googleDriveService) {
                            self.uploadFolderID = $0
                    }
                } else {
                    // Folder already exists
                    self.uploadFolderID = folderID
                }
        }
    }
    
    func uploadFile(name: String, folderID: String, fileURL: URL, service: GTLRDriveService) {
        
        let file = GTLRDrive_File()
        file.name = name
        file.parents = [folderID]
        
        // Optionally, GTLRUploadParameters can also be created with a Data object.
        let uploadParameters = GTLRUploadParameters(fileURL: fileURL, mimeType: "text/csv")
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)
        
        service.uploadProgressBlock = { _, totalBytesUploaded, totalBytesExpectedToUpload in
            // This block is called multiple times during upload and can
            // be used to update a progress indicator visible to the user.
        }
        
        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            // Successful upload if no error is returned.
        }
    }
    
    func createURL() -> URL {
        let fileName = "experiment.csv"
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        let csvText = dbm.getCSVString()
        do {
            try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        return path
    }
    
}

extension ExportViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        folderName = textField.text
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.folderNameTextField.resignFirstResponder()
        self.folderNameTextField.text = folderName
    }
}

