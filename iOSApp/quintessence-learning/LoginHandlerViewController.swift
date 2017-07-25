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
    @IBOutlet weak var nameField: UITextField!
    
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
            if error != nil {
                let errorMessage = error!.localizedDescription
                self.infoText.text! = errorMessage
                self.infoText!.isHidden = false;
            } else {
                let params = ["email" : self.emailText!.text!, "password": self.passField!.text!, "name": self.nameField!.text!, "uid": user!.uid] as [String: Any]
                    Server.post(urlRoute: self.signupUrl, params: params, callback: self.signUpCallback(data:), errorMessage: "Unable to sign up!")
            }
        }
    }
    
    @IBAction func forgotPasswordPress(_ sender: UIButton) {
        //TODO
    }
    
    func signUpCallback(data: Data) {
        Auth.auth().signIn(withEmail: self.emailText!.text!, password: self.passField!.text!) { (user, error) in
            if error != nil {
                let errorMessage = error!.localizedDescription
                self.infoText.text! = errorMessage
                self.infoText!.isHidden = false;
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
