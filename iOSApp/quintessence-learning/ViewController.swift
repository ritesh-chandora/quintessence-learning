//
//  ViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/18/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //redirects a logged in user to the appropriate view
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                user.
                let adminViewController = self.storyboard?.instantiateViewController(withIdentifier: "Admin") as! UINavigationController
                self.present(adminViewController, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
