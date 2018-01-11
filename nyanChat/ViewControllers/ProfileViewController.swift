//
//  ProfileViewController.swift
//  nyanChat
//
//  Created by George Tang on 1/10/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
// MARK: - Outlets
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var editPicLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBAction func logoutButtonTapped(_ sender: Any) {
        self.logout()
    }
    
    
// MARK: - Vars
    
    var imagePicker = UIImagePickerController()
    
    
// MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.title = "Profile" 
        
        let tapPic: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.selectPicSource))
        self.profilePicImageView.addGestureRecognizer(tapPic)
        Helpers().roundButtons([self.logoutButton])
        
        self.retrieveUsername()
        self.setImagePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.downloadProfilePic()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func turnToChatList() {
        Helpers().postToNotificationCenter("turnToChatList")
    }
    
// MARK: ProfilePic
    
    override func viewWillLayoutSubviews() {
        if self.profilePicImageView != nil {
            self.makePicCircular()
        }
    }
    
    private func makePicCircular() {
        self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.frame.size.width/2
        self.profilePicImageView.clipsToBounds = true
        self.profilePicImageView.layer.borderWidth = 2.5
        self.profilePicImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    
// MARK: - Storage

    private func downloadProfilePic() {
        let myID = Helpers().retrieveMyID()
        let profilePicRef = Storage.storage().reference().child("profilePic/\(myID).jpg")
        profilePicRef.downloadURL { url, error in
            if let error = error {
                print(error.localizedDescription)
                self.editPicLabel.isHidden = false
            } else {
                self.editPicLabel.isHidden = true
                self.profilePicImageView.sd_setImage(with: url)
            }
        }
    }

    
// MARK: - Firebase
    
    private func logout() {
        let helpers = Helpers()
        let auth = Auth.auth()
        do {
            try auth.signOut()
            helpers.postToNotificationCenter("turnToSignUp")
            self.dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            helpers.displayToast(self.view, message: error.localizedDescription)
        }
    }
    
    private func retrieveUsername() {
        let helpers = Helpers()
        let myID = helpers.retrieveMyID()
        let usernameRef = Database.database().reference().child("users").child(myID).child("username")
        
        usernameRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            if let username = snapshot.value as? String {
               self.usernameLabel.text = username
            } else {
                helpers.displayToast(self.view, message: "error")
            }
        })
    }

}


// MARK: - Image Picker

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String: Any]) {
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profilePicImageView.image = selectedImage
            self.view.layoutIfNeeded()
            self.makePicCircular()
            
            let myID = Helpers().retrieveMyID()
            FirebaseHelpers().uploadProflePic(selectedImage, myID: myID)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func selectPicSource() {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let takeSelfieAction = UIAlertAction(title: "Take a Selfie!", style: .default, handler: { action in
                    self.imagePicker.sourceType = .camera
                    self.imagePicker.cameraCaptureMode = .photo
                    self.imagePicker.cameraDevice = .front
                    self.present(self.imagePicker, animated: true, completion: nil)
                })
                alertController.addAction(takeSelfieAction)
            }
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let choosePhotoLibraryAction = UIAlertAction(title: "Choose from Photo Library", style: .default, handler: { action in
                    self.imagePicker.sourceType = .photoLibrary
                    self.present(self.imagePicker, animated: true, completion: nil)
                })
                alertController.addAction(choosePhotoLibraryAction)
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.view.tintColor = UIColor(red: 1.0/255.0, green: 68.0/255.0, blue: 121.0/255.0, alpha: 1.0)
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func setImagePicker() {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        self.imagePicker.modalPresentationStyle = .fullScreen
    }
    
}
