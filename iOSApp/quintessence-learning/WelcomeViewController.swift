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
        if timePicked {
            showPushNotifications()
            
        } else {
            Server.showError(message: "Please set a time!")
        }
    }
    
    func showPushNotifications(){
        let alert = UIAlertController(title: "Let us send you notifications?", message: "We will send you a question at the time you selected", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Don't Allow", style: .default))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: enableNotifications(sender: )))
        self.present(alert, animated: true)
    }
    
    func enableNotifications(sender: UIAlertAction){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if granted {
                print("permission granted")
            } else {
                print("denied")
            }
        }
    
        let userView = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UserTabBarController
        userView.isFirstTime = true
        userView.notifyTime = timePicker.date
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Type").setValue("User")
        self.present(userView, animated: true)
    }

    func createPicker(){
        timePicker.datePickerMode = .time
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        
        timeField.inputAccessoryView = toolbar
        timeField.inputView = timePicker
    }
    
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
