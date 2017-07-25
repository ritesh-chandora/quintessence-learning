//
//  LoginHandlerViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/19/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class LoginHandlerViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var infoText: UILabel!
    
    @IBOutlet weak var button: UIButton!

    let loginUrl = Server.hostURL + "/login"
    let signupUrl = Server.hostURL + "/signup"
    
    @IBAction func loginPress(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailText!.text!, password: passField!.text!) { (user, error) in
            if error != nil {
                let errorMessage = error!.localizedDescription
                print(errorMessage)
                self.infoText.text! = errorMessage
                self.infoText!.isHidden = false;
            }
        }
    }
    
    @IBAction func registerPress(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: emailText!.text!, password: passField!.text!) { (user, error) in
            print(error)
            if error != nil {
                let errorMessage = error!.localizedDescription
                self.infoText.text! = errorMessage
                self.infoText!.isHidden = false;
            } else {
                Auth.auth().signIn(withEmail: self.emailText!.text!, password: self.passField!.text!) { (user, error) in
                    if error != nil {
                        let errorMessage = error!.localizedDescription
                        self.infoText.text! = errorMessage
                        self.infoText!.isHidden = false;
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
