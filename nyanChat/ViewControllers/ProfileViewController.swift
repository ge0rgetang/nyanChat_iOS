//
//  ProfileViewController.swift
//  nyanChat
//
//  Created by George Tang on 1/10/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIPageViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var editPicLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBAction func logoutButtonTapped(_ sender: Any) {
    }
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
