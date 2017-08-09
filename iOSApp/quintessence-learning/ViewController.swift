//
//  ViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/18/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class ViewController: UIViewController {

    var ref : Database?
    var didViewChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database()
        if (Reachability.isConnectedToNetwork()){
            //redirects a logged in user to the appropriate view
            Auth.auth().addStateDidChangeListener() { auth, user in
                if user != nil {
                    self.ref!.reference().child(Common.USER_PATH).child(user!.uid).observe(.value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        let userType = value?["Type"] as? String ?? ""
                        if (userType == "user") {
                            let userViewController = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
                            self.present(userViewController, animated: true)
                            return
                        } else {
                            let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! UINavigationController
                            self.present(welcomeScreen, animated: true)
                            return
                        }
                    }) { (error) in
                        debugPrint("Failed get the snapshot \(error.localizedDescription)")
                    }
                }
                else {
                    let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! UINavigationController
                    self.present(welcomeScreen, animated: true)
                }
            }
        } else {
            Server.showError(message: "No internet connection detected! Please connect to the internet and try again.")
            let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! UINavigationController
            self.present(welcomeScreen, animated: true)
        }
    }
}

extension UIViewController {
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
