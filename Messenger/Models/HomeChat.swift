//
//  HomeChat.swift
//  Messenger
//
//  Created by Marton Zeisler on 2018. 09. 25..
//  Copyright © 2018. marton. All rights reserved.
//

import Foundation

class HomeChat{
    var partnerName: String?
    var partnerID: String?
    var partnerImageURL: String?
    var text: String?
    
    init(partnerName: String?, partnerID: String?, partnerImageURL: String?, text: String?) {
        self.partnerName = partnerName
        self.partnerID = partnerID
        self.partnerImageURL = partnerImageURL
        self.text = text
    }
}
