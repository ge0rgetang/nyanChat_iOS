//
//  SignUpViewController.swift
//  nyanChat
//
//  Created by George Tang on 1/10/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Toast_Swift

class SignUpViewController: UIViewController {
    
// MARK: - Outlets
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBAction func confirmButtonTapped(_ sender: Any) {
        self.signUp()
    }
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButtonTapped(_ sender: Any) {
        self.turnToLogin()
    }

    
// MARK: - Vars
    
    var doesUsernameExist: Bool = false
    
    
// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeNotifications()
        Helpers().hideToasts(self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
// MARK: - Navigation
    
    private func turnToLogin() {
        Helpers().postToNotificationCenter("turnToLogin")
    }
    
    
// MARK: - Keyboard
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        var userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 8
        self.scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    
// MARK: - Notification Center
    
    func setNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
// MARK: - Firebase
    
    private func checkUsername(_ username: String) {
        let helpers = Helpers()
        let usernameLowercase = username.lowercased()
        
        let userRef = Database.database().reference().child("users")
        userRef.queryOrdered(byChild: "usernameLower").queryEqual(toValue: usernameLowercase).observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists() {
                self.doesUsernameExist = true
                helpers.displayToast(self.view, message: "Username taken. Pick another.")
            } else {
                self.doesUsernameExist = false
            }
        })
    }
    
    private func signUp() {
        self.dismissKeyboard()
        let helpers = Helpers()
        helpers.displayToastActivity(self.view)
        
        let email: String = self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let username: String = self.usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password: String = self.passwordTextField.text!
        
        if email.isEmpty || password.isEmpty || username.isEmpty {
            helpers.displayToast(self.view, message: "Please fill the empty fields.")
            return
        }
        
        let atSet = CharacterSet(charactersIn: "@")
        if email.rangeOfCharacter(from: atSet) == nil {
            helpers.displayToast(self.view, message: "Please enter a valid email.")
            return
        }
        
        if password.count < 6 {
            helpers.displayToast(self.view, message: "Your pass needs to be at least 6 characters.")
            return
        }
        
        if helpers.checkSpecialCharacters(username) {
            helpers.displayToast(self.view, message:  "Only a-z, A-Z, 0-9, periods and underscores are allowed in username.")
            return
        }
        
        if self.doesUsernameExist {
            helpers.displayToast(self.view, message: "Username taken. Pick another.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                helpers.displayToast(self.view, message: error?.localizedDescription ?? "error")
                return
            } else {
                let uid = user!.uid
                self.setSignIn(email, password: password, username: username, userID: uid)
            }
        }
    }
    
    private func setSignIn(_ email: String, password: String, username: String, userID: String) {
        let helpers = Helpers()
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                helpers.displayToast(self.view, message: error?.localizedDescription ?? "error")
                return
            } else {
                UserDefaults.standard.set(userID, forKey: "myID")
                UserDefaults.standard.set(username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                let userRef = Database.database().reference().child("users").child(userID)
                userRef.child("email").setValue(email)
                userRef.child("username").setValue(username)
                userRef.child("usernameLowercase").setValue(username.lowercased())
                
                helpers.clearWebImageCache()
                helpers.postToNotificationCenter("turnToChatList")
            }
        }
    }
    
}


// MARK: - TextField

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1 {
            guard let text = textField.text else { return true }
            let length = text.count + string.count - range.length
            return length <= 15
        }
        
        guard let text = textField.text else { return true }
        let length = text.count + string.count - range.length
        return length <= 255
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 && textField.text != "" {
            let username = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            self.checkUsername(username)
        }
    }
    
}
