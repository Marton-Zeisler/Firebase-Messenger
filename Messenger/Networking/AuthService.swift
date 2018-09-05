//
//  AuthService.swift
//  Messenger
//
//  Created by Marton Zeisler on 2018. 08. 30..
//  Copyright © 2018. marton. All rights reserved.
//

import Foundation
import Firebase

class AuthService{
    static let instance = AuthService()
    
    // Sign Up with Email and Password
    func signUpUser(email: String, password: String, userImage: UIImage, userData: [String: Any], userCreationComplete: @escaping(_ success: Bool, _ error: Error?) ->Void ){
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard let result = authResult else {
                userCreationComplete(false, error)
                return
            }
            
            DataService.instance.createUser(uid: result.user.uid, email: email, userData: userData, profileImage: userImage, handler: { (success) in
                userCreationComplete(success, error)
            })
            
        }
    }
    
    // Sign In with Email and Password
    func signInUser(email: String, password: String, loginComplete: @escaping(_ success: Bool, _ error: Error?) ->Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil{
                loginComplete(false, error)
                return
            }
            
            loginComplete(true, nil)
        }
    }
    
    
    
    
    
    
    
    
}
