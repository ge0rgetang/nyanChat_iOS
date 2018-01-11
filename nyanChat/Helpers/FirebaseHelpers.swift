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
    
    func checkUsername(_ username: String, completion: @escaping(Bool) -> ()) {
        let usernameLowercase = username.lowercased()
        let userRef = Database.database().reference().child("users")
        userRef.queryOrdered(byChild: "usernameLowercase").queryEqual(toValue: usernameLowercase).observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    func observeChatList(completion: @escaping([ChatList]) -> ()) {
        self.removeChatListObserver()
        
        let helpers = Helpers()
        let currentReverseTimestamp = helpers.getCurrentReverseEpochTime()
        let myID = helpers.retrieveMyID()
        let chatListRef = self.ref.child("chatList").child(myID)
        
        
        chatListRef.queryOrdered(byChild: "reverseTimestamp").queryStarting(atValue: currentReverseTimestamp).queryLimited(toFirst: 42).observe(.value, with: { (snapshot) -> Void in
            if let dict = snapshot.value as? [String:Any] {
                var chatList: [ChatList] = []
                for entry in dict {
                    let chatID = entry.key
                    let chatValue = entry.value as? [String:Any] ?? [:]
                    
                    var chat = ChatList()
                    chat.chatID = chatID
                    chat.userID = chatValue["userID"] as? String ?? "0"
                    if let urlString = chatValue["profilePicURLString"] as? String {
                        chat.profilePicURL = URL(string: urlString)
                    }
                    chat.username = chatValue["username"] as? String ?? "0"
                    chat.message = chatValue["message"] as? String ?? "image sent"
                    let timestamp = chatValue["timestamp"] as? String ?? "error"
                    chat.timestamp = helpers.formatTimestamp(timestamp)
                    chat.reverseTimestamp = chatValue["reverseTimestamp"] as? Double ?? 0
                    
                    chatList.append(chat)
                }
                
                completion(chatList)
            }
        })
    }
    
    func removeChatListObserver() {
        let myID = Helpers().retrieveMyID()
        let chatListRef = self.ref.child("chatList").child(myID)
        chatListRef.removeAllObservers()
    }
    
    func observeConversation(_ chatID: String, completion: @escaping([Message]) -> ()) {
        self.removeConversationObserver(chatID)
        
        let helpers = Helpers()
        let currentReverseTimestamp = helpers.getCurrentReverseEpochTime()
        let conversationRef = self.ref.child("chats").child(chatID).child("messages")
        
        conversationRef.queryOrdered(byChild: "reverseTimestamp").queryStarting(atValue: currentReverseTimestamp).queryLimited(toFirst: 88).observe(.value, with: { (snapshot) -> Void in
            if let dict = snapshot.value as? [String:Any] {
                var messages: [Message] = []
                for entry in dict {
                    let messageID = entry.key
                    let messageValue = entry.value as? [String:Any] ?? [:]
                    
                    var message = Message()
                    message.messageID = messageID
                    message.userID = messageValue["userID"] as? String ?? "0"
                    if let urlString = messageValue["chatPicURLString"] as? String {
                        message.imagePicURL = URL(string: urlString)
                    }
                    message.message = messageValue["message"] as? String ?? "image sent"
                    
                    messages.append(message)
                }
                
                completion(messages)
            }
        })
    }
    
    func removeConversationObserver(_ chatID: String) {
        let conversationRef = self.ref.child("chats").child(chatID).child("messages")
        conversationRef.removeAllObservers()
    }
    
    func setTyping(_ amTyping: Bool, chatID: String, myID: String) {
        self.ref.child("chats").child("\(myID)_typing").setValue(amTyping)
    }
    
    func observeTyping(_ chatID: String, userID: String, completion: @escaping(Bool) -> ()) {
        self.removeTypingObserver(chatID, userID: userID)
        
        let typingRef = self.ref.child("chats").child(chatID).child("\(userID)_typing")
        typingRef.observe(.value, with: { (snapshot) -> Void in
            let isTyping = snapshot.value as? Bool ?? false
            completion(isTyping)
        })
    }
    
    func removeTypingObserver(_ chatID: String, userID: String) {
        let typingRef = self.ref.child("chats").child(chatID).child("\(userID)_typing")
        typingRef.removeAllObservers()
    }
    
    func sendMessage(_ chatID: String, userID: String, username: String, message: String?, url: URL, myURL: URL, view: UIView) {
        let helpers = Helpers()
        let myID = helpers.retrieveMyID()
        let myUsername = helpers.retrieveMyUsername()
        let timestamp = helpers.getTimestamp("UTC", date: Date())
        let reverseTimestamp = helpers.getCurrentReverseEpochTime()

        if message != nil && message != "" {
            let messageRef = self.ref.child("chats").child(chatID).child("messages").childByAutoId()
            messageRef.child("message").setValue(message!)
            messageRef.child("userID").setValue(myID)
            messageRef.child("reverseTimestamp").setValue(reverseTimestamp)
            
            let myChatListRef = self.ref.child("chatList").child(myID).child(chatID)
            myChatListRef.child("message").setValue(message!)
            myChatListRef.child("username").setValue(username)
            myChatListRef.child("timestamp").setValue(timestamp)
            myChatListRef.child("reverseTimestamp").setValue(reverseTimestamp)
            myChatListRef.child("profilePicURLString").setValue(url.absoluteString)
            
            let userChatListRef = self.ref.child("chatList").child(userID).child(chatID)
            userChatListRef.child("message").setValue(message!)
            userChatListRef.child("username").setValue(myUsername)
            userChatListRef.child("timestamp").setValue(timestamp)
            userChatListRef.child("reverseTimestamp").setValue(reverseTimestamp)
            userChatListRef.child("profilePicURLString").setValue(myURL.absoluteString)
        } else {
            helpers.displayToast(view, message: "Please type in some text.")
        }
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
    
    func uploadChatPic(_ image: UIImage, chatID: String, userID: String, username: String, url: URL, myURL: URL, view: UIView) {
        let helpers = Helpers()
        helpers.displayToastActivity(view)
        
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
        
        let messageRef = self.ref.child("chats").child(chatID).child("messages").childByAutoId()
        let messageID = messageRef.key

        if let newPicData = UIImageJPEGRepresentation(picSized, 1) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let chatPicRef = self.storageRef.child("chatPic/\(chatID)/\(messageID).jpg")
            
            chatPicRef.putData(newPicData, metadata: metadata) { metadata, error in
                if let error = error {
                    print(error.localizedDescription)
                    helpers.displayToast(view, message: error.localizedDescription)
                    return
                } else {
                    print("upload success")
                    let downloadURL = metadata!.downloadURL()
                    let picURLString = downloadURL!.absoluteString
                    
                    let myID = helpers.retrieveMyID()
                    let myUsername = helpers.retrieveMyUsername()
                    let timestamp = helpers.getTimestamp("UTC", date: Date())
                    let reverseTimestamp = helpers.getCurrentReverseEpochTime()
                    
                    let messageRef = self.ref.child("chats").child(chatID).child("messages").childByAutoId()
                    messageRef.child("chatPicURLString").setValue(picURLString)
                    messageRef.child("userID").setValue(myID)
                    messageRef.child("reverseTimestamp").setValue(reverseTimestamp)
                    
                    let myChatListRef = self.ref.child("chatList").child(myID).child(chatID)
                    myChatListRef.child("username").setValue(username)
                    myChatListRef.child("timestamp").setValue(timestamp)
                    myChatListRef.child("reverseTimestamp").setValue(reverseTimestamp)
                    myChatListRef.child("profilePicURLString").setValue(url.absoluteString)
                    
                    let userChatListRef = self.ref.child("chatList").child(userID).child(chatID)
                    userChatListRef.child("username").setValue(myUsername)
                    userChatListRef.child("timestamp").setValue(timestamp)
                    userChatListRef.child("reverseTimestamp").setValue(reverseTimestamp)
                    userChatListRef.child("profilePicURLString").setValue(myURL.absoluteString)
                    
                    helpers.hideToasts(view)
                }
            }
        }
        
    }
    
}
