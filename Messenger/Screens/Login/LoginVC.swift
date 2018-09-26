//
//  ViewController.swift
//  Messenger
//
//  Created by Marton Zeisler on 2018. 08. 30..
//  Copyright © 2018. marton. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var inputsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdtextField: UITextField!
    @IBOutlet weak var seperatorView: UIView!
    var indicatorView: UIActivityIndicatorView?
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIsLogin(true)
        hideKeyboardWhenTappedAround()
        firstTextField.delegate = self
        secondTextField.delegate = self
        thirdtextField.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstTextField{
            secondTextField.becomeFirstResponder()
        }else if textField == secondTextField && segmentedControl.selectedSegmentIndex == 0{
            loginButtonTapped(self)
        }else{
            thirdtextField.becomeFirstResponder()
        }
        
        return true
    }

    @IBAction func selectedSegmented(_ sender: UISegmentedControl) {
        sender.selectedSegmentIndex == 0 ? setIsLogin(true) : setIsLogin(false)
    }
    
    func setIsLogin(_ isLogin: Bool){
        firstTextField.text = ""
        secondTextField.text = ""
        thirdtextField.text = ""
        
        if isLogin{ // Login
            addImageButton.isHidden = true
            imageButton.isEnabled = false
            inputsHeightConstraint.constant = 101
            thirdtextField.isHidden = true
            seperatorView.isHidden = true
            UIView.performWithoutAnimation {
                self.loginButton.setTitle("Login", for: .normal)
                self.loginButton.layoutIfNeeded()
            }
            firstTextField.placeholder = "Email address"
            firstTextField.keyboardType = .emailAddress
            firstTextField.autocapitalizationType = .none
            secondTextField.placeholder = "Password"
            secondTextField.keyboardType = .default
            secondTextField.isSecureTextEntry = true
            secondTextField.returnKeyType = .go
        }else{ // Register
            addImageButton.isHidden = false
            imageButton.isEnabled = true
            inputsHeightConstraint.constant = 150
            thirdtextField.isHidden = false
            seperatorView.isHidden = false
            UIView.performWithoutAnimation {
                self.loginButton.setTitle("Register", for: .normal)
                self.loginButton.layoutIfNeeded()
            }
            firstTextField.placeholder = "Name"
            firstTextField.keyboardType = .default
            firstTextField.autocapitalizationType = .words
            secondTextField.placeholder = "Email address"
            secondTextField.keyboardType = .emailAddress
            secondTextField.isSecureTextEntry = false
            secondTextField.returnKeyType = .continue
        }
    }
    
    @IBAction func imageTapped(_ sender: UIButton) {
        addImageTapped(self)
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheetVC.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        actionSheetVC.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        actionSheetVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let alertPop = actionSheetVC.popoverPresentationController{
            alertPop.sourceView = addImageButton
            alertPop.sourceRect = CGRect(x: addImageButton.frame.width/2, y: addImageButton.frame.height, width: 0, height: 10)
        }
        
        present(actionSheetVC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        UIApplication.shared.statusBarStyle = .lightContent
        
        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage else { return }
        imageButton.setImage(image, for: .normal)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        if let errorMessage = isInputCorrect(){
            let alertVC = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }else{
            segmentedControl.selectedSegmentIndex == 0 ? completeLogin() : completeRegister()
        }
    }
    
    func setIndicatorVisible(_ bool: Bool){
        if bool{
            indicatorView = UIActivityIndicatorView(style: .whiteLarge)
            indicatorView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3483164613)
            indicatorView?.frame = view.frame
            view.addSubview(indicatorView!)
            indicatorView?.startAnimating()
        }else{
            indicatorView?.removeFromSuperview()
        }
    }
    
    func completeLogin(){
        setIndicatorVisible(true)
        AuthService.instance.signInUser(email: firstTextField.text!, password: secondTextField.text!) { (success, error) in
            if success{
                self.performSegue(withIdentifier: "next", sender: nil)
                self.setIndicatorVisible(false)
            }else{
                self.setIndicatorVisible(false)
                 print("Firebase: Sign In error: ", error.debugDescription)
                let alertVC = UIAlertController(title: "Sign In Error", message: "Wrong email or password!", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    func completeRegister(){
        setIndicatorVisible(true)
        AuthService.instance.signUpUser(email: secondTextField.text!, password: thirdtextField.text!, userImage: imageButton.imageView!.image!, userData: ["name" : firstTextField.text!]) { (success, error) in
            if success == true{
                print("Firebase: Sign up successfull")
                self.performSegue(withIdentifier: "next", sender: nil)
                self.setIndicatorVisible(false)
            }else{
                self.setIndicatorVisible(false)
                print("Firebase: Sign up error: ", error!.localizedDescription)
                if error!.localizedDescription == "The email address is already in use by another account."{
                    let alertVC = UIAlertController(title: "Email Taken", message: "Please use a different email address!", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)
                }else{
                    let alertVC = UIAlertController(title: "Sign Up Error", message: "Please try again!", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func isInputCorrect() -> String?{ // Returns error message if there is an error
        if segmentedControl.selectedSegmentIndex == 0{ // Login
            if firstTextField.text?.isValidEmail() == false { return "Please enter a valid email address." }
            if secondTextField.text!.count < 6 { return "Please enter a minimum 6 character long password." }
        }else{ // Register
            if firstTextField.hasText == false { return "Please enter your name." }
            if secondTextField.text?.isValidEmail() == false { return "Please enter a valid email address." }
            if thirdtextField.text!.count < 6 { return "Please enter a minimum 6 character long password." }
            if imageButton.image(for: .normal) == UIImage(named: "defaultProfilePic") { return "Please upload a profile picture." }
            
        }
        return nil
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

}




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
