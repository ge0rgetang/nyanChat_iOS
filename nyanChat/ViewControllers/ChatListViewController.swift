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
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.chatListTableView.delegate = self
        self.setSideMenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - Navigation
    
    
    // MARK - SideMenu
    
    private func setSideMenu() {
        if let sideMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "SideMenuNavigationController") as? UISideMenuNavigationController {
            sideMenuNavigationController.leftSide = true
            SideMenuManager.default.menuLeftNavigationController = sideMenuNavigationController
            SideMenuManager.default.menuPresentMode = .menuSlideIn
            SideMenuManager.default.menuAnimationBackgroundColor = UIColor(red: 1.0/255.0, green: 28.0/255.0, blue: 121.0/255/0, alpha: 1.0)
            SideMenuManager.default.menuAnimationFadeStrength = 0.35
            SideMenuManager.default.menuAnimationTransformScaleFactor = 1.0
            SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
            SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: UIRectEdge.left)
        }
    }

}


// MARK: - TableView

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
