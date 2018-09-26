//
//  DataService.swift
//  Messenger
//
//  Created by Marton Zeisler on 2018. 08. 30..
//  Copyright © 2018. marton. All rights reserved.
//

import Foundation
import Firebase
import MessageKit

let DB_BASE = Database.database().reference()
let ST_BASE = Storage.storage().reference()

class DataService{
    static let instance = DataService()
    
    private var _DB_REF_BASE = DB_BASE
    private var _DB_REF_USERS = DB_BASE.child("users")
    private var _DB_REF_USERMESSAGES = DB_BASE.child("user-messages")
    private var _DB_REF_MESSAGES = DB_BASE.child("messages")
    
    private var _ST_REF_USERS = ST_BASE.child("profile-images")
    
    var DB_REF_BASE: DatabaseReference{
        return _DB_REF_BASE
    }
    
    var DB_REF_USERS: DatabaseReference{
        return _DB_REF_USERS
    }
    
    var DB_REF_USERMESSAGES: DatabaseReference{
        return _DB_REF_USERMESSAGES
    }
    
    var DB_REF_MESSAGES: DatabaseReference{
        return _DB_REF_MESSAGES
    }
    
    var ST_REF_USERS: StorageReference{
        return _ST_REF_USERS
    }
    
    func createUser(uid: String, email: String, userData: Dictionary<String, Any>, profileImage: UIImage, handler: @escaping(_ success: Bool) ->Void ){
        DB_REF_USERS.child(uid).updateChildValues(userData)
        DB_REF_USERS.child(uid).child("email").setValue(email)
        
        if let imageData = profileImage.jpegData(compressionQuality: 0.1){
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
    
    func sendMessage(senderID: String, receiverID: String, chatText: String, handler: @escaping(_ messageID: String) ->Void){
        // Message
        let messageID = DB_REF_MESSAGES.childByAutoId()
        let timeStamp = Int(Date().timeIntervalSince1970)
        messageID.updateChildValues(["text": chatText, "senderID": senderID, "time": timeStamp])
        
        // Sender
        DB_REF_USERMESSAGES.child(senderID).child(receiverID).child("lastMessage").setValue(chatText)
        DB_REF_USERMESSAGES.child(senderID).child(receiverID).child("chats").updateChildValues([messageID.key: 1])
        
        // Receiver
        DB_REF_USERMESSAGES.child(receiverID).child(senderID).child("lastMessage").setValue(chatText)
        DB_REF_USERMESSAGES.child(receiverID).child(senderID).child("chats").updateChildValues([messageID.key: 1])
        handler(messageID.key)
    }
    
    func loadMessages(senderID: String, receiverID: String, handler: @escaping(_ messages: [Message]?) ->Void){
        var messages = [Message]()

        DB_REF_USERMESSAGES.child(senderID).child(receiverID).child("chats").observe(.childAdded) { (snapshot) in
            let messageID = snapshot.key
            self.DB_REF_MESSAGES.child(messageID).observeSingleEvent(of: .value, with: { (msgSnapshot) in
                let senderID = msgSnapshot.childSnapshot(forPath: "senderID").value as? String
                let text = msgSnapshot.childSnapshot(forPath: "text").value as? String
                let time = msgSnapshot.childSnapshot(forPath: "time").value as? Int
                if senderID != nil && text != nil && time != nil{
                    let message = Message(sender: Sender(id: senderID!, displayName: "Sender"), messageId: messageID, sentDate: Date(), data: MessageData.text(text!), time: time!)
                    messages.append(message)
                    handler(messages)
                }
            })
        }
        
    }
    
    func loadHomeChats(userID: String, handler: @escaping(_ homeChats: [String: HomeChat]?) ->Void){
        var homeChats = [String: HomeChat]()
        
        DB_REF_USERMESSAGES.child(userID).observe(.childAdded) { (snapshot) in
            let partnerID = snapshot.key
            
            self.DB_REF_USERMESSAGES.child(userID).child(partnerID).child("lastMessage").observe(.value, with: { (snapshot2) in
                let last = snapshot2.value as? String
                self.getUserProfileURL(userID: partnerID, handler: { (url) in
                    let profileURL = url
                    print(profileURL)
                    self.getUserName(uid: partnerID, handler: { (userName) in
                        let name = userName
                        homeChats[partnerID] = HomeChat(partnerName: name, partnerID: partnerID, partnerImageURL: profileURL, text: last)
                        handler(homeChats)
                    })
                    
                })
                
            })
            

        }
    }
    
    func getUserProfileURL(userID: String, handler: @escaping(_ profileURL: String) ->Void){
        DB_REF_USERS.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let url = snapshot.childSnapshot(forPath: "profilePicURL").value as? String{
                handler(url)
            }
        }
    }
    
    
}
