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
import UserNotifications
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
                debugPrint(errorMessage)
                self.infoText.text! = errorMessage
                self.infoText!.isHidden = false;
                self.toggleButtons(toggle: true)
            } else if (!Auth.auth().currentUser!.isEmailVerified) {
                
                //FIRST CHECK - is the email verified? if not, redirect to email verification screen
                
                let emailScreen = self.storyboard?.instantiateViewController(withIdentifier: "VerifyEmail") as! EmailVerificationViewController
                emailScreen.email = Auth.auth().currentUser!.email!
                self.navigationController?.pushViewController(emailScreen, animated: true)
            } else {
                
                //SECOND CHECK - ACCOUNT TYPES
                
                self.ref!.reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).child("Old_Time").observeSingleEvent(of: .value, with: { (old_time) in
                    self.ref!.reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).child("Time").observeSingleEvent(of: .value, with: { (time) in
                        
                        //initially set the notification timers
                        let oldTime = old_time.value as? TimeInterval ?? nil
                        
                        if (oldTime != nil){
                            let oldDate = Date(timeIntervalSince1970: oldTime!)
                            Common.setNotificationTimer(date: oldDate, repeating: false, daily: false)
                        }
                        
                        let currTime = time.value as? TimeInterval ?? nil
                        
                        //if currTime is nil, then user hasn't initiailzed a time and bring them to the welcome screen
                        if (currTime != nil) {
                            
                            //Check if notifications have been asked for before
                            
                            if (!UserDefaults.standard.bool(forKey: "AskedForNotifications")) {
                                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                                    (granted, error) in
                                    if granted {
                                        UserDefaults.standard.set(true, forKey: "AskedForNotifications")
                                        Common.showSuccess(message: "Warning: First notification may be off by 24 hours!")
                                    } else {
                                    }
                                }
                            }
                            
                            self.ref!.reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (value) in
                                let value = value.value as? NSDictionary
                                let type = value?["Type"] as? String ?? ""

                                //if basic, then redirect normally with week as the interval
                                if (type == "basic"){
                                    Common.timeInterval = Common.weekInSeconds
                                    Common.setNotificationTimer(date: Date(timeIntervalSince1970: currTime!), repeating: true, daily: false)
                                    let userViewController = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
                                    self.present(userViewController, animated: true)
                                } else if (type == "premium"){
                                    //check if still subscribed
                                    if (!SubscriptionService.shared.hasReceiptData!) {
                                            //show premium screen if not
                                            let premiumScreen = self.storyboard?.instantiateViewController(withIdentifier: "Premium") as! PremiumPurchaseViewController
                                            self.present(premiumScreen, animated: true)
                                            return
                                    } else {
                                        Common.timeInterval = Common.dayInSeconds
                                        
                                        let notifyTime = Date(timeIntervalSince1970: currTime!)
                                        Common.setNotificationTimer(date: notifyTime, repeating: true, daily: true)
                                        let profileView = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
                                        self.present(profileView, animated:true)
                                        return
                                    }
                                } else if (type == "premium_trial") {
                                    //check if trial is expired
                                    let joinDateSinceEpoch = value?["Join_Date"] as! TimeInterval
                                    
                                    //Firebase uses milliseconds while Swift uses seconds, need to do conversion
                                    //calculate number of days left in trial
                                    let timeElapsed = Double(Common.trialLength) * Common.dayInSeconds - (Date().timeIntervalSince1970 - joinDateSinceEpoch/1000)
                                    if (timeElapsed <= 0){
                                        let premiumScreen = self.storyboard?.instantiateViewController(withIdentifier: "Premium") as! PremiumPurchaseViewController
                                        self.present(premiumScreen, animated: true)
                                    } else {
                                        Common.setNotificationTimer(date: Date(timeIntervalSince1970: currTime!), repeating: true, daily: true)
                                        let userViewController = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
                                        self.present(userViewController, animated: true)
                                    }
                                    
                                }
                            })
                        } else {
                            let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
                            self.present(welcomeScreen, animated: true)
                        }
                    })
                })
                
                
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
                                  "Type":"none",
                                  "Ebook":false,
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
                self.present(ac, animated: true)
            } else {
                Auth.auth().sendPasswordReset(withEmail: fieldText!, completion: { (Error) in
                    if let error = Error {
                        Server.showError(message: error.localizedDescription)
                        self.present(ac, animated: true)
                    } else {
                        Common.showSuccess(message: "Email sent!")
                    }
                })
            }
        }))
        
        self.present(ac, animated: true)
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
        Auth.auth().currentUser!.sendEmailVerification { (error) in
            
        }
        let emailScreen = self.storyboard?.instantiateViewController(withIdentifier: "VerifyEmail") as! EmailVerificationViewController
        emailScreen.email = self.emailText!.text!
        emailScreen.first = self.nameField!.text!
        emailScreen.last = self.lastNameField!.text!
        self.navigationController?.pushViewController(emailScreen, animated: true)
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
        scrollView.setContentOffset(CGPoint(x:0, y:100), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
    
}
