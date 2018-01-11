//
//  Helpers.swift
//  nyanChat
//
//  Created by George Tang on 1/10/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import Foundation
import Toast_Swift
import SDWebImage

class Helpers {
    
// MARK: - User Defaults
    
    func saveMyID(_ id: String) {
        UserDefaults.standard.set(id, forKey: "myID")
        UserDefaults.standard.synchronize()
    }
    
    func retrieveMyID() -> String {
        if let id = UserDefaults.standard.string(forKey: "myID") {
            return id
        } else {
            return "0"
        }
    }
    
    func retrieveMyUsername() -> String {
        if let un = UserDefaults.standard.string(forKey: "username") {
            return un
        } else {
            return "0"
        }
    }
    
// MARK: - Notification Center
    
    func postToNotificationCenter(_ name: String) {
        NotificationCenter.default.post(name: Notification.Name(name), object: nil)
    }
    
    
// MARK: - Toast
    
    func displayToast(_ view: UIView, message: String) {
        view.hideAllToasts()
        view.makeToast(message, duration: 2.0, position: .top)
    }
    
    func displayToastActivity(_ view: UIView) {
        view.makeToastActivity(.center)
    }
    
    func hideToasts(_ view: UIView) {
        view.hideAllToasts()
    }
    
    
// MARK: - Time
    
    func formatTimestamp(_ timestampString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: timestampString)
        
        dateFormatter.dateFormat = "h:mm a MMM dd, yyyy"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        let timestamp = dateFormatter.string(from: date!)
        return timestamp
    }
    
    func getTimestamp(_ zone: String, date: Date) -> String {
        let dateFormatter = DateFormatter()
        if zone == "UTC" {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        } else {
            dateFormatter.dateFormat = "h:mm a MMM dd, yyyy"
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        }
        return dateFormatter.string(from: date)
    }
    
    func getCurrentReverseEpochTime() -> Double {
        return (0 - Date().timeIntervalSince1970)
    }

    
// MARK: - SDWebImage
    
    func clearWebImageCache() {
        let imageCache = SDImageCache.shared()
        imageCache.clearMemory()
        imageCache.clearDisk()
    }
    
    
// MARK: - Strings
    
    func checkSpecialCharacters(_ string: String) -> Bool {
        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789._")
        if string.rangeOfCharacter(from: set.inverted) != nil {
            return true
        } else {
            return false
        }
    }
    
}
