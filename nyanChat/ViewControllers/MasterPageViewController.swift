//
//  MasterPageViewController.swift
//  nyanChat
//
//  Created by George Tang on 1/10/18.
//  Copyright © 2018 George Tang. All rights reserved.
//

import UIKit

class MasterPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTurnToPageObservers()
        self.setInitalPage()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Navigation
    
    private func addTurnToPageObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.turnToSignUp), name: Notification.Name("turnToSignUp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.turnToLogin), name: Notification.Name("turnToLogin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.turnToProfile), name: Notification.Name("turnToProfile"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.turnToChatList), name: Notification.Name("turnToChatList"), object: nil)
    }
    
    @objc private func turnToSignUp() {
        let vc = self.orderedViewControllers[0]
        setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    }
    
    @objc private func turnToLogin() {
        let vc = self.orderedViewControllers[1]
        setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    }
    
    @objc private func turnToProfile() {
        let vc = self.orderedViewControllers[2]
        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }
    
    @objc private func turnToChatList() {
        let vc = self.orderedViewControllers[3]
        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }
    
    private func setInitalPage() {
        let myID = Helpers().retrieveMyID()
        
        var vc: UIViewController
        if myID == "0" {
            vc = self.orderedViewControllers[0]
        } else {
            vc = self.orderedViewControllers[3]
        }
        
        setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    }
    
    
    // MARK: - Child ViewControllers
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController("SignUpViewController"),
                self.newViewController("LoginViewController"),
                self.newViewController("ProfileViewController"),
                self.newViewController("ChatListNavigationController")]
    } ()
    
    private func newViewController(_ storyboardID: String) -> UIViewController {
        switch storyboardID {
        default:
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(storyboardID)")
        }
    }

    
    // MARK: - PageViewController Protocol
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = self.orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard self.orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return self.orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = self.orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        let orderedViewControllersCount = self.orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return self.orderedViewControllers[nextIndex]
    }

}
