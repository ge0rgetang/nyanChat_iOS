//
//  ChatList.swift
//  nyanChat
//
//  Created by George Tang on 1/11/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import Foundation

struct ChatList {
    var chatID: String = "0"
    var userID: String = "0"
    var profilePicURL: URL?
    var username: String = "error"
    var message: String = "error"
    var timestamp: String = "error"
    var reverseTimestamp: Double = 0
}
