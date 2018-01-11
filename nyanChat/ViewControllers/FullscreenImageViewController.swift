//
//  FullscreenImageViewController.swift
//  nyanChat
//
//  Created by George Tang on 1/10/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import UIKit

class FullscreenImageViewController: UIViewController {
    
// MARK: - Outlets
    
    @IBOutlet weak var fullscreenImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
// MARK: - Vars

    var image: UIImage!
    var messageID: String = "0"
    
    
// MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fullscreenImageView.image = self.image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
