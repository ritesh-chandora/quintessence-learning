//
//  NewTimeViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/30/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import UserNotifications
protocol UpdateTimeLabel {
    func updateTimeLabel(newDate:Date) -> Void
}

class NewTimeViewController: ModalViewController {
    
    var timePicker = UIDatePicker()
    
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    
    var timePicked = false
    let dateFormatter = DateFormatter()
    var userRef:DatabaseReference?
    var timeLabelDelegate:UpdateTimeLabel?
    
    @IBAction override func onClose(_ sender: UIButton) {
        super.onClose(sender)
    }
    
    @IBAction func onSubmit(_ sender: UIButton) {
        if (timePicked) {
            userRef!.child("Old_Time").observeSingleEvent(of: .value, with: { (data) in
                
                let oldTime = data.value as? TimeInterval ?? nil
                self.userRef!.child("Time").observeSingleEvent(of: .value, with: { (time) in
                    
                    //keep old time for one cycle, then update to the new time
                    let currNotifyTime = Date(timeIntervalSince1970: (time.value as! TimeInterval))
                    
                    //offset new time with weekend, if needed
                    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let components = calendar.dateComponents([.weekday], from: currNotifyTime)
                    
                    //if it is friday thru sunday, don't notify and add appropriate time to next question
                    if (Common.weekend.contains(components.weekday!)) {
                        var days = 0
                        if(components.weekday == 6) {
                            //friday, add 3 days to it
                            days+=3
                        } else if (components.weekday == 7){
                            //saturday, add 2 days
                            days+=2
                        } else if (components.weekday == 1) {
                            //sunday, add one day
                            days+=1
                        }
                        self.timePicker.date.addTimeInterval(Common.dayInSeconds*Double(days))
                    }
                    
                    //if the next notification time is too close to the new set notification time (within 12 hours), add another day
                    if oldTime != nil {
                        if (abs(currNotifyTime.timeIntervalSince1970 - oldTime!) < Common.dayInSeconds/2){
                            self.timePicker.date.addTimeInterval(Common.dayInSeconds)
                        }
                    } else if (abs(currNotifyTime.timeIntervalSince1970 - self.timePicker.date.timeIntervalSince1970 - Common.dayInSeconds) < Common.dayInSeconds/2){
                        self.timePicker.date.addTimeInterval(Common.dayInSeconds)
                    }
                    
                    let newNotifyTime = self.timePicker.date.addingTimeInterval(Common.dayInSeconds)
                    
                    
                    //ask user to confirm
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .short
                    dateFormatter.dateStyle = .short
                    
                    let ac = UIAlertController(title: "Confirm New Time", message: "After your next question, which is at \(dateFormatter.string(from: currNotifyTime)), your next question will be at \(dateFormatter.string(from: newNotifyTime))", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                        super.onClose(sender)
                    }))
                    ac.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
                        self.userRef!.child("Time").setValue(newNotifyTime.timeIntervalSince1970)
                        
                        //cancel all pending notifications
                        let center = UNUserNotificationCenter.current()
                        center.removeAllPendingNotificationRequests()
                        
                        //if there already isn't an old notification time set
                        if oldTime == nil {
                            self.userRef!.child("Old_Time").setValue(currNotifyTime.timeIntervalSince1970)
                            
                            //set one notification timer for this last notification at that time
                            Common.setNotificationTimer(date: currNotifyTime, repeating: false)
                        }
                        //set new notification timer
                        Common.setNotificationTimer(date: newNotifyTime, repeating: true)
                        
                        //update the label on ProfileViewController
                        self.timeLabelDelegate?.updateTimeLabel(newDate: newNotifyTime)
                        Common.showSuccess(message: "Warning: Notifications may take up to 24 hours to take effect!")
                        self.timeField.text = self.dateFormatter.string(from: newNotifyTime)
                        super.onClose(sender)
                    }))
                    self.present(ac,animated: true)
                })
            })
        } else {
            //don't change time if no time was picked
            super.onClose(sender)
        }
    }
    
    override func viewDidLoad() {
        createPicker()
        dateFormatter.timeStyle = .short
        
        userRef = Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid)
        
        //set the current notification date label
        userRef!.child("Time").observeSingleEvent(of: .value, with: { (time) in
            self.timeLabel.text! = self.dateFormatter.string(from: Date(timeIntervalSince1970: time.value as! TimeInterval))
        })
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isOpaque = false
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

}

