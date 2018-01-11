//
//  ConversationViewController.swift
//  nyanChat
//
//  Created by George Tang on 1/10/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import UIKit
import FirebaseStorage

class ConversationViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var conversationTableView: UITableView!
    @IBOutlet weak var typingLabel: UILabel!
    @IBOutlet weak var typingLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var sendTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBAction func sendButtonTapped(_ sender: Any) {
        let message = self.sendTextView.text
        FirebaseHelpers().sendMessage(self.chatID, userID: self.userID, username: self.username, message: message, url: self.profilePicURL, myURL: self.myProfilePicURL, view: self.view)
    }
    @IBOutlet weak var cameraButton: UIButton!
    @IBAction func cameraButtonTapped(_ sender: Any) {
        self.setImagePicker()
    }
    
    
// MARK: - Vars
    
    var chatID: String = "0"
    var userID: String = "0"
    var username: String = "nyanChat"
    var profilePicURL: URL!
    var myProfilePicURL: URL!
    var imageToPass: UIImage!
    var imagePicker = UIImagePickerController()
    var messages: [Message] = []
    
    var isTyping: Bool = false {
        didSet {
            if self.isTyping != oldValue {
                self.showTyping()
            }
        }
    }
    
    
// MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.title = self.username
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        self.setTextView()
        self.setImagePicker()
        self.setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setNotifications()
        self.downloadProfilePicURL()
        self.downloadMyProfilePicURL()
        
        let firebaseHelpers = FirebaseHelpers()
        firebaseHelpers.observeConversation(self.chatID, completion: {(messages) in
            self.messages = messages
            self.conversationTableView.reloadData()
        })
        firebaseHelpers.observeTyping(self.chatID, userID: self.userID, completion: { (isTyping) in
            self.isTyping = isTyping
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeNotifications()
        
        let firebaseHelpers = FirebaseHelpers()
        firebaseHelpers.removeConversationObserver(self.chatID)
        firebaseHelpers.removeTypingObserver(self.chatID, userID: self.userID)
        let myID = Helpers().retrieveMyID()
        firebaseHelpers.setTyping(false, chatID: self.chatID, myID: myID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

// MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromConversationToFullscreenImageSegue" {
            if let vc = segue.destination as? FullscreenImageViewController {
                vc.image = self.imageToPass
            }
        }
    }
    
    @objc func presentFullscreenImage(_ sender: UITapGestureRecognizer) {
        let position = sender.location(in: self.conversationTableView)
        let indexPath: IndexPath! = self.conversationTableView.indexPathForRow(at: position)
        let message = self.messages[indexPath.row]
        
        if let imagePicURL = message.imagePicURL {
            let imageView = UIImageView()
            imageView.sd_setImage(with: imagePicURL)
            self.imageToPass = imageView.image
            self.performSegue(withIdentifier: "fromConversationToFullscreenImageSegue", sender: self)
        }
    }

    
// MARK: - Keyboard
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = -keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
// MARK: - Notification Center
    
    func setNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(_:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    
// MARK: - Typing View
    
    private func showTyping() {
        if self.isTyping {
            UIView.animate(withDuration: 0.25, animations: {
                self.typingLabel.alpha = 1
                self.typingLabelHeight.constant = 30
                self.typingLabel.layoutIfNeeded()
                self.conversationTableView.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
                self.typingLabel.alpha = 0
                self.typingLabel.layoutIfNeeded()
            }, completion: { (finished:Bool) in
                if finished {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.typingLabelHeight.constant = 0
                        self.conversationTableView.layoutIfNeeded()
                        self.typingLabel.layoutIfNeeded()
                    })
                }
            })
        }
    }
    
    
    // MARK: - Storage
    
    func downloadMyProfilePicURL() {
        let myID = Helpers().retrieveMyID()
        let profilePicRef = Storage.storage().reference().child("profilePic/\(myID).jpg")
        profilePicRef.downloadURL { url, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.myProfilePicURL = url
            }
        }
    }
    
    func downloadProfilePicURL() {
        let profilePicRef = Storage.storage().reference().child("profilePic/\(self.userID).jpg")
        profilePicRef.downloadURL { url, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.profilePicURL = url
            }
        }
    }
    
}


// MARK: - TableView

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setTableView() {
        self.conversationTableView.delegate = self
        self.conversationTableView.dataSource = self
        self.conversationTableView.rowHeight = UITableViewAutomaticDimension
        self.conversationTableView.estimatedRowHeight = 100
        self.conversationTableView.layoutMargins = UIEdgeInsets.zero
        self.conversationTableView.separatorInset = UIEdgeInsets.zero
        self.conversationTableView.showsVerticalScrollIndicator = false
        self.conversationTableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.messages.count == 0 {
            return 1
        }
        
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.messages.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noTextCell", for: indexPath) as! NoContentTableViewCell
            cell.noContentLabel.sizeToFit()
            return cell
        }
        
        let message = self.messages[indexPath.row]
        let userID = message.userID 
        if let imagePicURL = message.imagePicURL {
            var cell: ImageTableViewCell
            
            if userID == self.userID {
                cell = tableView.dequeueReusableCell(withIdentifier: "receivedImageCell", for: indexPath) as! ImageTableViewCell
                cell.profilePicImageView.sd_setImage(with: self.profilePicURL)
                cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.frame.size.width/2
                cell.profilePicImageView.clipsToBounds = true
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "sentImageCell", for: indexPath) as! ImageTableViewCell
            }
            
            cell.picImageView.sd_setImage(with: imagePicURL)
            let tapPic = UITapGestureRecognizer(target: self, action: #selector(self.presentFullscreenImage))
            cell.picImageView.addGestureRecognizer(tapPic)
            setImageAspectRatio(cell, image: cell.picImageView.image)
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)

            return cell
        } else {
            var cell: TextTableViewCell
            
            if userID == self.userID {
                cell = tableView.dequeueReusableCell(withIdentifier: "receivedTextCell", for: indexPath) as! TextTableViewCell
                cell.profilePicImageView.sd_setImage(with: self.profilePicURL)
                cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.frame.size.width/2
                cell.profilePicImageView.clipsToBounds = true
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "sentTextCell", for: indexPath) as! TextTableViewCell
            }
            
            cell.messageLabel.text = message.message
            cell.bubbleView.layer.cornerRadius = 2.5
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)

            return cell
        }
    }
    
    private func setImageAspectRatio(_ cell: ImageTableViewCell, image: UIImage?) {
        if let img = image {
            let h = img.size.height
            let w = img.size.width
            if w >= h {
                cell.aspectWideConstraint.isActive = true
                cell.aspectTallConstraint.isActive = false
            }  else {
                cell.aspectWideConstraint.isActive = false
                cell.aspectTallConstraint.isActive = true
            }
        } else {
            cell.aspectWideConstraint.isActive = true
            cell.aspectTallConstraint.isActive = false
        }
    }
    
}


// MARK: - TextView

extension ConversationViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
            let myID = Helpers().retrieveMyID()
            FirebaseHelpers().setTyping(true, chatID: self.chatID, myID: myID)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let currentLength = textView.text.count + (text.count - range.length)
        var charactersLeft = 255 - currentLength
        if charactersLeft < 0 {
            charactersLeft = 0
        }
        
        if currentLength >= 213 {
            self.characterCountLabel.isHidden = false
            self.characterCountLabel.text = "\(charactersLeft)"
            self.characterCountLabel.textColor = UIColor.lightGray
        } else {
            self.characterCountLabel.isHidden = true
        }
        
        return currentLength <= 255
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "send a message..."
            textView.textColor = .lightGray
            self.characterCountLabel.isHidden = true
            let myID = Helpers().retrieveMyID()
            FirebaseHelpers().setTyping(false, chatID: self.chatID, myID: myID)
        }
    }
    
    func setTextView() {
        self.sendTextView.delegate = self
        self.sendTextView.textColor = .lightGray
        self.sendTextView.text = "send a message..."
        self.sendTextView.isScrollEnabled = false
        self.sendTextView.layer.cornerRadius = 5
        self.sendTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        self.sendTextView.layer.borderWidth = 0.5
        self.sendTextView.clipsToBounds = true
        self.sendTextView.layer.masksToBounds = true
        self.sendTextView.autocorrectionType = .default
        self.sendTextView.spellCheckingType = .default
    }
    
}


// MARK: - Image Picker

extension ConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info:[String: Any]) {
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            FirebaseHelpers().uploadChatPic(selectedImage, chatID: self.chatID, userID: self.userID, username: self.username, url: self.profilePicURL, myURL: self.myProfilePicURL, view: self.view)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func selectPicSource() {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let takePicAction = UIAlertAction(title: "Camera", style: .default, handler: { action in
                    self.imagePicker.sourceType = .camera
                    self.imagePicker.cameraCaptureMode = .photo
                    self.imagePicker.cameraDevice = .rear
                    self.present(self.imagePicker, animated: true, completion: nil)
                })
                alertController.addAction(takePicAction)
            }
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let choosePhotoLibraryAction = UIAlertAction(title: "Choose from Photo Library", style: .default, handler: { action in
                    self.imagePicker.sourceType = .photoLibrary
                    self.present(self.imagePicker, animated: true, completion: nil)
                })
                alertController.addAction(choosePhotoLibraryAction)
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.view.tintColor = UIColor(red: 1.0/255.0, green: 68.0/255.0, blue: 121.0/255/0, alpha: 1.0)
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func setImagePicker() {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        self.imagePicker.modalPresentationStyle = .fullScreen
    }
    
}
