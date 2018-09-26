//
//  Message.swift
//  Messenger
//
//  Created by Marton Zeisler on 2018. 09. 23..
//  Copyright © 2018. marton. All rights reserved.
//

import Foundation
import MessageKit

struct Message: MessageType{
    
    var sender: Sender
    var messageId: String
    var sentDate: Date
    var data: MessageData
    var time: Int
    
    init(sender: Sender, messageId: String, sentDate: Date, data: MessageData, time: Int) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.data = data
        self.time = time
    }
}


