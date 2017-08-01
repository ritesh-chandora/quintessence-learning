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

    var ref : Database?
    let loginUrl = Server.hostURL + "/login"
    let signupUrl = Server.hostURL + "/signup"
    
    @IBAction func loginPress(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailText!.text!, password: passField!.text!) { (user, error) in
            if error != nil {
                let errorMessage = error!.localizedDescription
                print(errorMessage)
                self.infoText.text! = errorMessage
                self.infoText!.isHidden = false;
            } else {
                let profileView = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
                self.present(profileView, animated:true)
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
                let params = ["Current_Question": 0,
                              "Email" : self.emailText!.text!,
                              "Join_Date": ServerValue.timestamp(),
                              "Name": self.nameField!.text!,
                              "Trial":true,
                              "Type":"none",
                              "UID": user!.uid] as NSDictionary
                self.ref!.reference().child("Users").child(user!.uid).setValue(params) { (err, ref) in
                    if let err = err {
                        Server.showError(message: "Error in signing up: " + err.localizedDescription)
                    } else {
                        self.signUpCallback()
                    }
                }
            }
        }
    }
    
    @IBAction func forgotPasswordPress(_ sender: UIButton) {
        //TODO
    }
    
    func signUpCallback() {
        let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
        present(welcomeScreen, animated: true)
//        Auth.auth().signIn(withEmail: self.emailText!.text!, password: self.passField!.text!) { (user, error) in
//            if error != nil {
//                let errorMessage = error!.localizedDescription
//                self.infoText.text! = errorMessage
//                self.infoText!.isHidden = false;
//            }
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
