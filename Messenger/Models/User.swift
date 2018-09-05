//
//  User.swift
//  Messenger
//
//  Created by Marton Zeisler on 2018. 08. 31..
//  Copyright © 2018. marton. All rights reserved.
//

import Foundation

class User: Equatable{
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
                lhs.name == rhs.name &&
                lhs.email == rhs.email &&
                lhs.profileImageURL == rhs.profileImageURL
    }
    
    
    var id: String?
    var name: String?
    var email: String?
    var profileImageURL: String?
    
    init(id: String?, name: String?, email: String?, profileImageURL: String?) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageURL = profileImageURL
    }
}
