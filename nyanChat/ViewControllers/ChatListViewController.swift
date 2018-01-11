//
//  ChatListViewController.swift
//  nyanChat
//
//  Created by George Tang on 1/10/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import UIKit
import SDWebImage
import SideMenu

class ChatListViewController: UIViewController {
    
// MARK: - Outlets
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    
// MARK: - Vars

    var chatIDToPass: String = "0"
    var userIDToPass: String = "0"
    var usernameToPass: String = "nyanChat"
    var chats: [ChatList] = []
    
    
// MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTableView()
        self.setSideMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseHelpers().observeChatList(completion: {(chats) in
            self.chats = chats
            self.chatListTableView.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        FirebaseHelpers().removeChatListObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

// MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromChatListToConversationSegue" {
            if let vc = segue.destination as? ConversationViewController {
                vc.chatID = self.chatIDToPass
                vc.userID = self.userIDToPass
                vc.username = self.usernameToPass
            }
        }
    }
    
    
// MARK - SideMenu
    
    private func setSideMenu() {
        if let sideMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "SideMenuNavigationController") as? UISideMenuNavigationController {
            sideMenuNavigationController.leftSide = true
            SideMenuManager.default.menuLeftNavigationController = sideMenuNavigationController
            SideMenuManager.default.menuPresentMode = .menuSlideIn
            SideMenuManager.default.menuAnimationBackgroundColor = UIColor(red: 1.0/255.0, green: 68.0/255.0, blue: 121.0/255.0, alpha: 1.0)
            SideMenuManager.default.menuAnimationFadeStrength = 0.35
            SideMenuManager.default.menuAnimationTransformScaleFactor = 1.0
            SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
            SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: UIRectEdge.left)
        }
    }
    
}


// MARK: - TableView

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setTableView() {
        self.chatListTableView.delegate = self
        self.chatListTableView.dataSource = self
        self.chatListTableView.rowHeight = UITableViewAutomaticDimension
        self.chatListTableView.estimatedRowHeight = 100
        self.chatListTableView.layoutMargins = UIEdgeInsets.zero
        self.chatListTableView.separatorInset = UIEdgeInsets.zero
        self.chatListTableView.showsVerticalScrollIndicator = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.chats.count == 0 {
            return 1
        }
        
        return self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.chats.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noChatListCell", for: indexPath) as! NoContentTableViewCell
            cell.noContentLabel.sizeToFit()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatListCell", for: indexPath) as! ChatListTableViewCell
        let chat = self.chats[indexPath.row]
        
        if let profilPicURL = chat.profilePicURL {
            cell.profilePicImageView.sd_setImage(with: profilPicURL)
        } 
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.frame.size.width/2
        cell.profilePicImageView.clipsToBounds = true
        
        cell.usernameLabel.text = chat.username
        cell.timestampLabel.text = chat.timestamp
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.chats.isEmpty {
            let chat = self.chats[indexPath.row]
            self.usernameToPass = chat.username
            self.chatIDToPass = chat.chatID
            self.userIDToPass = chat.userID
            self.performSegue(withIdentifier: "fromChatListToConversationSegue", sender: self)
        }
    }
    
}
