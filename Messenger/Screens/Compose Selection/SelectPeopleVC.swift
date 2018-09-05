//
//  SelectPeopleVC.swift
//  Messenger
//
//  Created by Marton Zeisler on 2018. 08. 31..
//  Copyright © 2018. marton. All rights reserved.
//

import UIKit
import Firebase

class SelectPeopleVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    var selectedUserIndexes = [Int]()
    var currentUserID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        currentUserID = Auth.auth().currentUser?.uid
        loadUsers()
    }
    
    func loadUsers(){
        DataService.instance.getUsers { (users) in
            if let users = users {
                for each in users{
                    if each.id != self.currentUserID{
                        self.users.append(each)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func setupNavBar(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SelectPeopleCell
        cell.nameLabel.text = users[indexPath.row].name ?? ""
        if let imageURL = users[indexPath.row].profileImageURL{
            cell.profileImageView.loadImageUsingCacheWithUrlString(imageURL)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if let indexToRemove = selectedUserIndexes.index(of: indexPath.row){
                selectedUserIndexes.remove(at: indexToRemove)
                cell.accessoryType = .none
            }else{
                selectedUserIndexes.append(indexPath.row)
                cell.accessoryType = .checkmark
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    
    @objc func cancelTapped(_ button: UIBarButtonItem){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneTapped(_ button: UIBarButtonItem){
        if selectedUserIndexes.count > 0 {
            
        }else{
            let alertVC = UIAlertController(title: "Select a person", message: "Select at least 1 person from the list to start a chat!", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }



}
