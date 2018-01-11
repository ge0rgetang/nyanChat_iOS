//
//  FirebaseHelpers.swift
//  nyanChat
//
//  Created by George Tang on 1/11/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

class FirebaseHelpers {
    
    // MARK: - Database
    
    var ref = Database.database().reference()
    func retrieveUsername(_ userID: String) {
        
    }
    
    
    // MARK: - Storage
    
    let storageRef = Storage.storage().reference()

    func uploadProflePic(_ image: UIImage, myID: String) {
        var picSized: UIImage!
        let sourceWidth = image.size.width
        let sourceHeight = image.size.height
        
        var scaleFactor: CGFloat!
        if sourceWidth > sourceHeight {
            scaleFactor = 250/sourceWidth
        } else {
            scaleFactor = 250/sourceHeight
        }
        
        let newWidth = scaleFactor*sourceWidth
        let newHeight = scaleFactor*sourceHeight
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        picSized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let newPicData = UIImageJPEGRepresentation(picSized, 1) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let profilePicRef = self.storageRef.child("profilePic/\(myID).jpg")
            
            profilePicRef.putData(newPicData, metadata: metadata) { metadata, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    let downloadURL = metadata!.downloadURL()
                    let urlString = downloadURL!.absoluteString
                    self.ref.child("users").child(myID).child("profilePicURLString").setValue(urlString)
                    print("upload success")
                }
            }
        }
        
    }
    
    func uploadChatPic(_ image: UIImage, chatID: String, messageID: String) {
        var picSized: UIImage!
        let sourceWidth = image.size.width
        let sourceHeight = image.size.height
        
        var scaleFactor: CGFloat!
        if sourceWidth > sourceHeight {
            scaleFactor = 1080/sourceWidth
        } else {
            scaleFactor = 1080/sourceHeight
        }
        
        let newWidth = scaleFactor*sourceWidth
        let newHeight = scaleFactor*sourceHeight
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        picSized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let newPicData = UIImageJPEGRepresentation(picSized, 1) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let chatPicRef = self.storageRef.child("chatPic/\(chatID)/\(messageID).jpg")
            
            chatPicRef.putData(newPicData, metadata: metadata) { metadata, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                } else {
                    let downloadURL = metadata!.downloadURL()
                    let urlString = downloadURL!.absoluteString
                    self.ref.child("chats").child(chatID).child(messageID).child("chatPicURLString").setValue(urlString)
                    print("upload success")
                }
            }
        }
        
    }
    
}
