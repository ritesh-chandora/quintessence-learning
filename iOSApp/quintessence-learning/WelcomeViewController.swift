//
//  WelcomeViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/25/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseAuth
import FirebaseDatabase
class WelcomeViewController: UIViewController {
    
    
    let timePicker = UIDatePicker()
    var timePicked = false
    @IBOutlet weak var timeField: UITextField!
    
    @IBAction func getStartedPress(_ sender: UIButton) {
        //set it to initially trigger the next day
        debugPrint(Common.timeInterval)
        Common.timeInterval = Common.dayInSeconds
        timePicker.date.addTimeInterval(Common.timeInterval)
        
        if timePicked {
            showPushNotifications()
            
        } else {
            Server.showError(message: "Please set a time!")
        }
    }
    
    //alert controller to explain the need for push notifs
    func showPushNotifications(){
        let alert = UIAlertController(title: "Let us send you notifications?", message: "We will alert you when a new question has arrived", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Don't Allow", style: .default))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: enableNotifications(sender: )))
        self.present(alert, animated: true)
    }
    
    //request notifications and then advances to user dashboard
    func enableNotifications(sender: UIAlertAction){
        let notifyDays = [0,1,1,1,1,1,0]
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if granted {
                UserDefaults.standard.set(true, forKey: "AskedForNotifications")
                debugPrint("permission granted")
                Common.showSuccess(message: "First notification may be off by 24 hours!")
                Common.showSuccess(message: "You're all set! Your 90 day trial begins now. You will be given the option to convert to basic or continue premium once the trial period is over. You will NOT be automatically charged")
                Common.showSuccess(message: "Your premium trial has started! You will begin receiving questions once a day, not including weekends. You can change time/day as you want")
               //Common.setNotificationTimer(date: self.timePicker.date, repeating: true, daily: true)
               Common.setNotificationTimer(date: self.timePicker.date, isRepeating: true, repeatingDays: notifyDays)
                
            } else {
                debugPrint("denied")
                print("WelcomeView User did not provide the required permission to show notificaiton")
            }
        }
        
        let userView = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
        
        //initialize the account to be a user and initializes the time
        Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).child("Type").setValue("premium_trial")
    Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).child("Time").setValue(timePicker.date.timeIntervalSince1970)
    Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).child("NotificationDays").setValue(notifyDays.map(String.init).joined(separator: ","))
        self.present(userView, animated: true)
    }

    //initializes the time picker to be shown upon tapping the text field
    func createPicker(){
        timePicker.datePickerMode = .time
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        
        timeField.inputAccessoryView = toolbar
        timeField.inputView = timePicker
    }
    
    //handler for timePicker done being pressed
    func donePressed(){
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        timeField.text = dateFormatter.string(from: timePicker.date)
        self.view.endEditing(true)
        timePicked = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPicker()
    }
    
}
