//
//  MessagesVC.swift
//  Messenger
//
//  Created by Marton Zeisler on 2018. 08. 31..
//  Copyright © 2018. marton. All rights reserved.
//

import UIKit
import Firebase

class MessagesVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        loadData()
    }
    
    func loadData(){
        // Loading user name for title
        if let user = Auth.auth().currentUser{
            DataService.instance.getUserName(uid: user.uid) { (name) in
                if let name = name{
                    self.title = name
                }
            }
        }
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
