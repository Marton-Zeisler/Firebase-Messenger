//
//  ChatVC.swift
//  Messenger
//
//  Created by Marton Zeisler on 2018. 09. 23..
//  Copyright © 2018. marton. All rights reserved.
//

import UIKit
import MessageKit
import Firebase

class ChatVC: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageInputBarDelegate {
    
    var messages = [Message]()
    
    var receiver: User?
    var currentUserPhotoURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = receiver?.name ?? ""
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let senderID = Auth.auth().currentUser?.uid, let receiverID = receiver?.id {
            DataService.instance.getUserProfileURL(userID: senderID) { (url) in
                self.currentUserPhotoURL = url
            }
            
            DataService.instance.loadMessages(senderID: senderID, receiverID: receiverID) { (chat) in
                self.messages = chat ?? self.messages
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
        }
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        messagesCollectionView.scrollToBottom()
    }
    
    
    func currentSender() -> Sender {
        if let senderID = Auth.auth().currentUser?.uid{
            return Sender(id: senderID, displayName: "Sender")
        }
        return Sender(id: "123", displayName: "Cicu")
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 100
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if let receiverID = receiver?.id, let currentUserPhotoURL = currentUserPhotoURL{
            if message.sender.id == receiverID{
                avatarView.loadImageUsingCacheWithUrlString((receiver?.profileImageURL!)!)
            }else{
                avatarView.loadImageUsingCacheWithUrlString(currentUserPhotoURL)
            }
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.id == receiver?.id{
            return UIColor(red: 240/255, green: 240/255, blue: 242/255, alpha: 1.0)
        }else{
            return UIColor(red: 43/255, green: 158/255, blue: 249/255, alpha: 1.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == messages.count-1{
            return UIEdgeInsets(top: 4, left: 8, bottom: 20, right: 8)
        }else if section == 0{
            return UIEdgeInsets(top: 20, left: 8, bottom: 4, right: 8)
        }else{
            return UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        if let senderID = Auth.auth().currentUser?.uid, let receiverID = receiver?.id {
            
            DataService.instance.sendMessage(senderID: senderID, receiverID: receiverID, chatText: text) { (messageID) in
                self.messages.append(Message(sender: Sender(id: senderID, displayName: "Sender"), messageId: messageID, sentDate: Date(), data: MessageData.text(text), time: Int(Date().timeIntervalSince1970)))
                self.messagesCollectionView.reloadDataAndKeepOffset()
            }
            
            
            inputBar.inputTextView.text = ""
            let controller = MessagesViewController()
            controller.resignFirstResponder()
        }
    }
    
    
    
    
    
}
