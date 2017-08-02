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
class LoginHandlerViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var infoText: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    
    @IBOutlet weak var button: UIButton!

    var ref : Database?
    let loginUrl = Server.hostURL + "/login"
    let signupUrl = Server.hostURL + "/signup"
    
    @IBAction func loginPress(_ sender: UIButton) {
        toggleButtons(toggle: false)
        Auth.auth().signIn(withEmail: emailText!.text!, password: passField!.text!) { (user, error) in
            if error != nil {
                let errorMessage = error!.localizedDescription
                print(errorMessage)
                self.infoText.text! = errorMessage
                self.infoText!.isHidden = false;
                self.toggleButtons(toggle: true)
            } else {
                let profileView = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
                self.present(profileView, animated:true)
            }
        }
    }
    
    @IBAction func registerPress(_ sender: UIButton) {
        if (nameField!.text! == "" || lastNameField!.text! == "") {
            let errorMessage = "Enter all fields!"
            self.infoText.text! = errorMessage
            self.infoText!.isHidden = false;
        } else if (passField!.text! != confirmPassField!.text!){
            let errorMessage = "Passwords do not match!"
            self.infoText.text! = errorMessage
            self.infoText!.isHidden = false;
            passField!.text = ""
            confirmPassField!.text = ""
        } else {
            toggleButtons(toggle: false)
            Auth.auth().createUser(withEmail: emailText!.text!, password: passField!.text!) { (user, error) in
                if error != nil {
                    let errorMessage = error!.localizedDescription
                    self.infoText.text! = errorMessage
                    self.infoText!.isHidden = false;
                    self.toggleButtons(toggle: true)
                } else {
                    let params = ["Current_Question": 0,
                                  "Email" : self.emailText!.text!,
                                  "Join_Date": ServerValue.timestamp(),
                                  "Name": "\(self.nameField!.text!) \(self.lastNameField!.text!)",
                                  "Trial":true,
                                  "Type":"none",
                                  "UID": user!.uid] as NSDictionary
                    self.ref!.reference().child("Users").child(user!.uid).setValue(params) { (err, ref) in
                        if let err = err {
                            Server.showError(message: "Error in signing up: " + err.localizedDescription)
                            self.toggleButtons(toggle: true)
                        } else {
                            self.signUpCallback()
                        }
                    }
                }
            }

        }
    }
    
    //send a reset password link to the user with the given email
    @IBAction func forgotPasswordPress(_ sender: UIButton) {
        let ac = UIAlertController(title: "Forgot Password", message: "Please enter your email below", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        ac.addTextField { (textfield) in
            textfield.placeholder = "Email"
        }
        
        ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            let fieldText = ac.textFields?[0].text!
            if (fieldText! == ""){
                Server.showError(message: "Enter an email!")
            } else {
                Auth.auth().sendPasswordReset(withEmail: fieldText!, completion: { (Error) in
                    if let error = Error {
                        Server.showError(message: error.localizedDescription)
                    } else {
                        Common.showSuccess(message: "Email sent!")
                    }
                })
            }
        }))
        
        present(ac, animated: true)
    }

    func toggleButtons(toggle:Bool){
        DispatchQueue.main.async {
            self.button.isEnabled = toggle
            if (toggle){
                if (self.button.titleLabel?.text! == "Logging In...") {
                    self.button.setTitle("Login", for: .normal)
                } else {
                    self.button.setTitle("Sign Up", for: .normal)
                }
            } else {
                if (self.button.titleLabel?.text! == "Login"){
                    self.button.setTitle("Logging In...", for: .normal)
                } else {
                    self.button.setTitle("Signing Up...", for: .normal)
                }
            }
        }
    }
    
    func signUpCallback() {
        let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
        present(welcomeScreen, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database()
        self.hideKeyboardOnTap()
    }
    
    // - UITEXTFIELD METHODS
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0, y:250), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
    
}
