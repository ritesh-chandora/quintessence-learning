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
    @IBOutlet weak var confirmPassField: UITextField!
    
    @IBOutlet weak var button: UIButton!

    var ref : Database?
    let loginUrl = Server.hostURL + "/login"
    let signupUrl = Server.hostURL + "/signup"
    
    @IBAction func loginPress(_ sender: UIButton) {
        self.button.isEnabled = false
        self.button.setTitle("Logging In...", for: .normal)
        
        Auth.auth().signIn(withEmail: emailText!.text!, password: passField!.text!) { (user, error) in
            if error != nil {
                let errorMessage = error!.localizedDescription
                debugPrint(errorMessage)
                self.infoText.text! = errorMessage
                self.infoText!.isHidden = false;
                self.button.isEnabled = true
                self.button.setTitle("Login", for: .normal)
            }
            else if (!Auth.auth().currentUser!.isEmailVerified) {
                
                //FIRST CHECK - is the email verified? if not, redirect to email verification screen
                let emailScreen = self.storyboard?.instantiateViewController(withIdentifier: "VerifyEmail") as! EmailVerificationViewController
                emailScreen.email = Auth.auth().currentUser!.email!
                self.navigationController?.pushViewController(emailScreen, animated: true)
            }
            else {
                
                //SECOND CHECK - ACCOUNT TYPES
                
                self.ref!.reference(withPath: ".info/serverTimeOffset").observe(.value, with: { dateSnapShot in
                    if let offset = dateSnapShot.value as? TimeInterval {
                        let currentTimeStamp = (Date().timeIntervalSince1970*1000 + offset) / 1000 //GetItFromServer
                        self.ref!.reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                            let userInfo = snapshot.value as? NSDictionary
                            if let userInfo = userInfo {
                                let userNotifyTime:TimeInterval?
                                var userNotifyOldTime:TimeInterval?
                                let userNotifyDays:String?
                                let userNotifyOldDays:String?
                                let userType:String? // = value?["Type"] as? String ?? ""
                                let userJoinDate = userInfo["Join_Date"] as! TimeInterval
                                
                                if userInfo["Time"] != nil{
                                    userNotifyTime = userInfo["Time"] as? TimeInterval ?? nil
                                }
                                else{
                                    userNotifyTime = nil
                                }
                                
                                if userInfo["Old_Time"] != nil{
                                    userNotifyOldTime = userInfo["Old_Time"] as? TimeInterval ?? nil
                                }
                                else{
                                    userNotifyOldTime = nil
                                }
                                
                                if userInfo["NotificationDays"] != nil{
                                    userNotifyDays = userInfo["NotificationDays"] as? String ?? nil
                                }
                                else{
                                    userNotifyDays = nil
                                }
                                
                                if userInfo["Old_NotificationDays"] != nil{
                                    userNotifyOldDays = userInfo["Old_NotificationDays"] as? String ?? nil
                                }
                                else{
                                    userNotifyOldDays = nil
                                }
                                
                                if userInfo["Type"] != nil{
                                    userType = userInfo["Type"] as? String ?? nil
                                }
                                else{
                                    userType = nil
                                }
                                
                                //print("lets print values. userNotifiyTime \(userNotifyTime!) usernotifyDays \(userNotifyDays!)")
                                
                                //initially set the notification timers
                                if (userNotifyOldTime != nil){
                                    print("user is having old time \(userNotifyOldTime!).")
                                    let oldDate = Date(timeIntervalSince1970: userNotifyOldTime!)
                                    //if user old account then set only once the notification
                                    //Common.setNotificationTimer(date: oldDate, repeating: false, daily: false)
                                    Common.setNotificationTimer(date: oldDate, isRepeating: false, repeatingDays: nil)
                                }
                                
                                if (userNotifyTime != nil) {
                                    //Check if notifications have been asked for before
                                    if (!UserDefaults.standard.bool(forKey: "AskedForNotifications")) {
                                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                                            (granted, error) in
                                            if granted {
                                                UserDefaults.standard.set(true, forKey: "AskedForNotifications")
                                                Common.showSuccess(message: "Warning: First notification may be off by 24 hours!")
                                            } else {
                                                print("LoginHandler User did not provide the required permission to show notificaiton")
                                            }
                                        }
                                    }
                                    
                                    let notifyTime_Date = Date(timeIntervalSince1970: userNotifyTime!)
                                    
                                    //if basic, then redirect normally with week as the interval
                                    if (userType == "basic"){
                                        //Common.timeInterval = Common.weekInSeconds
                                        //Common.setNotificationTimer(date: Date(timeIntervalSince1970: currTime!), repeating: true, daily: false)
                                        
                                        var notifyDays = [0,0,0,0,0,0,0]
                                        notifyDays[Calendar(identifier: Calendar.Identifier.gregorian).dateComponents([.weekday], from: notifyTime_Date).weekday! - 1] = 1;
                                        Common.setNotificationTimer(date: notifyTime_Date, isRepeating: true, repeatingDays: notifyDays)
                                        
                                        let userViewController = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
                                        self.present(userViewController, animated: true)
                                    } else if (userType == "premium"){
                                        //check if still subscribed
                                        SubscriptionService.shared.hasReceiptData = true
                                        if (!SubscriptionService.shared.hasReceiptData!) {
                                            //show premium screen if not
                                            let premiumScreen = self.storyboard?.instantiateViewController(withIdentifier: "Premium") as! PremiumPurchaseViewController
                                            self.present(premiumScreen, animated: true)
                                            return
                                        } else {
                                            print("Premimum Account")
                                            Common.timeInterval = Common.dayInSeconds
                                            //Common.setNotificationTimer(date: notifyTime, repeating: true, daily: true)
                                            Common.setNotificationTimer(date: notifyTime_Date, isRepeating: true, repeatingDays: userNotifyDays!.components(separatedBy: ",").map({ (x:String) -> Int in return Int(x)! }))
                                            let profileView = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
                                            self.present(profileView, animated:true)
                                            return
                                        }
                                    } else if (userType == "premium_trial") {
                                        //check if trial is expired
                                        //let userJoinDate = value?["Join_Date"] as! TimeInterval
                                        
                                        //Firebase uses milliseconds while Swift uses seconds, need to do conversion
                                        //calculate number of days left in trial
                                        let timeElapsed = Double(Common.trialLength) * Common.dayInSeconds - (currentTimeStamp - userJoinDate/1000)
                                        if (timeElapsed <= 0){
                                            let premiumScreen = self.storyboard?.instantiateViewController(withIdentifier: "Premium") as! PremiumPurchaseViewController
                                            self.present(premiumScreen, animated: true)
                                        }
                                        else {
                                            Common.timeInterval = Common.dayInSeconds
                                            //Common.setNotificationTimer(date: Date(timeIntervalSince1970: currTime!), repeating: true, daily: true)
                                            Common.setNotificationTimer(date: notifyTime_Date, isRepeating: true, repeatingDays: userNotifyDays!.components(separatedBy: ",").map({ (x:String) -> Int in return Int(x)! }))
                                            let userViewController = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
                                            self.present(userViewController, animated: true)
                                        }
                                        
                                    }
                                    
                                }
                                else {
                                    let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
                                    self.present(welcomeScreen, animated: true)
                                }
                            }
                            
                        })
                        
                        
                        
                    }
                })
               
            }
        }
     }
    
    @IBAction func registerPress(_ sender: UIButton) {
        if (nameField!.text! == "" /*|| lastNameField!.text! == "" */) {
            let errorMessage = "Enter all fields!"
            self.infoText.text! = errorMessage
            self.infoText!.isHidden = false;
        }
        else if (passField!.text! != confirmPassField!.text!){
            let errorMessage = "Passwords do not match!"
            self.infoText.text! = errorMessage
            self.infoText!.isHidden = false;
            passField!.text = ""
            confirmPassField!.text = ""
        }
        else {
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
                                  "Name": "\(self.nameField!.text!)",
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
        //emailScreen.last = self.lastNameField!.text!
        self.present(emailScreen, animated: true)
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
