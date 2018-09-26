//
//  MessagesVC.swift
//  Messenger
//
//  Created by Marton Zeisler on 2018. 08. 31..
//  Copyright © 2018. marton. All rights reserved.
//

import UIKit
import Firebase

class MessagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var homeChats = [HomeChat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        setupNavBar()
        loadData()
    }
    
    
    func loadData(){
        // Loading user name for title
        if let user = Auth.auth().currentUser{
            DataService.instance.loadHomeChats(userID: user.uid) { (chats) in
                if let chats = chats{
                    self.homeChats = Array(chats.values)
                }
                self.tableView.reloadData()
            }
            DataService.instance.getUserName(uid: user.uid) { (name) in
                if let name = name{
                    self.title = name
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HomeCell
        if let name = homeChats[indexPath.row].partnerName{
            cell.NameLabel.text = name
        }
        
        if let url = homeChats[indexPath.row].partnerImageURL{
            cell.profileImage.loadImageUsingCacheWithUrlString(url)
        }
        
        if let text = homeChats[indexPath.row].text{
            cell.lastLabel?.text = text
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatVC = storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.receiver = User(id: homeChats[indexPath.row].partnerID, name: homeChats[indexPath.row].partnerName, email: nil, profileImageURL: homeChats[indexPath.row].partnerImageURL)
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
    func setupNavBar(){
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeTapped))
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }

    @objc func logOutTapped(_ button: UIBarButtonItem){
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "logOut", sender: nil)
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }catch let error{
            print("Firebase: Sign out unsuccessful: ", error.localizedDescription)
        }
    }
    
    @objc func composeTapped(_ button: UIBarButtonItem){
        if let selectPeopleVC = storyboard?.instantiateViewController(withIdentifier: "SelectPeopleVC"){
            present(selectPeopleVC, animated: true, completion: nil)
        }
        
    }

}
