//
//  LoginViewController.swift
//  nyanChat
//
//  Created by George Tang on 1/10/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
// MARK: - Outlets
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBAction func confirmButtonTapped(_ sender: Any) {
        self.login()
    }
    @IBOutlet weak var signUpButton: UIButton!
    @IBAction func signUpButtonTapped(_ sender: Any) {
        self.turnToSignUp()
    }

    
// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
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
    
    private func turnToSignUp() {
        Helpers().postToNotificationCenter("turnToSignUp")
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
    
    private func login() {
        let helpers = Helpers()
        helpers.displayToastActivity(self.view)
        
        let email: String = self.emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password: String = self.passwordTextField.text!
        
        if email.isEmpty || password.isEmpty {
            helpers.displayToast(self.view, message: "Please fill the empty fields.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                helpers.displayToast(self.view, message: error?.localizedDescription ?? "error")
                return
            } else {
                let userID = user!.uid
                let usernameRef = Database.database().reference().child("users").child(userID).child("username")
                
                usernameRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                    if let username = snapshot.value as? String {
                        UserDefaults.standard.set(userID, forKey: "myID")
                        UserDefaults.standard.set(username, forKey: "username")
                        UserDefaults.standard.synchronize()
                        
                        helpers.clearWebImageCache()
                        helpers.postToNotificationCenter("turnToChatList")
                    } else {
                        helpers.displayToast(self.view, message: "error")
                    }
                })
            }
        }
        
    }

}


// MARK: - TextField

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let length = text.count + string.count - range.length
        return length <= 255
    }
    
}
