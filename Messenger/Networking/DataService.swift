//
//  DataService.swift
//  Messenger
//
//  Created by Marton Zeisler on 2018. 08. 30..
//  Copyright © 2018. marton. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = Database.database().reference()
let ST_BASE = Storage.storage().reference()

class DataService{
    static let instance = DataService()
    
    private var _DB_REF_BASE = DB_BASE
    private var _DB_REF_USERS = DB_BASE.child("users")
    
    private var _ST_REF_USERS = ST_BASE.child("profile-images")
    
    var DB_REF_BASE: DatabaseReference{
        return _DB_REF_BASE
    }
    
    var DB_REF_USERS: DatabaseReference{
        return _DB_REF_USERS
    }
    
    var ST_REF_USERS: StorageReference{
        return _ST_REF_USERS
    }
    
    func createUser(uid: String, email: String, userData: Dictionary<String, Any>, profileImage: UIImage, handler: @escaping(_ success: Bool) ->Void ){
        DB_REF_USERS.child(uid).updateChildValues(userData)
        DB_REF_USERS.child(uid).child("email").setValue(email)
        
        if let imageData = UIImageJPEGRepresentation(profileImage, 0.1){
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            ST_REF_USERS.child(uid).child("profileImage.jpg").putData(imageData, metadata: metadata, completion:  { (metadata, error) in
                if error != nil{
                    print("Firebase: Unable to upload image to Firebase storage: ", String(describing: error))
                    handler(false)
                }else{
                    print("Firebase: Successfully uploaded image to Firebase")
                    self.ST_REF_USERS.child(uid).child("profileImage.jpg").downloadURL(completion: { (url, error) in
                        if error != nil{
                            print("Firebase: Unable to get URL link of uploaded image: ", String(describing: error))
                            handler(false)
                        }else{
                            if let imageURL = url?.absoluteString{
                                self.DB_REF_USERS.child(uid).child("profilePicURL").setValue(imageURL)
                                handler(true)
                            }else{
                                handler(false)
                            }
                        }
                    })
                }
            })
        }else{
            handler(false)
        }
    }
    
    func getUserName(uid: String, handler: @escaping(_ name: String?) ->Void){
        DB_REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let name = snapshot.childSnapshot(forPath: "name").value as? String
            handler(name)
        }
    }
    
    func getUsers(handler: @escaping(_ users: [User]?) ->Void){
        var users = [User]() 
        
        DB_REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            guard let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                handler(nil)
                return
            }
            
            for each in userSnapshot{
                let id = each.key
                let email = each.childSnapshot(forPath: "email").value as? String
                let name = each.childSnapshot(forPath: "name").value as? String
                let profileImageURL = each.childSnapshot(forPath: "profilePicURL").value as? String
                users.append(User(id: id, name: name, email: email, profileImageURL: profileImageURL))
            }
            
            handler(users)
        }
    }
    
    
}
