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
                print("fuck")
                let oldTime = data.value as? TimeInterval ?? nil
                self.userRef!.child("Time").observeSingleEvent(of: .value, with: { (time) in
                    
                    //keep old time for one cycle, then update to the new time
                    let currNotifyTime = Date(timeIntervalSince1970: (time.value as! TimeInterval))
                    
                    //if the next notification time is too close to the new set notification time (within 12 hours), add another day
                    if oldTime != nil {
                        if (abs(currNotifyTime.timeIntervalSince1970 - oldTime!) < Common.dayInSeconds/2){
                            self.timePicker.date.addTimeInterval(Common.dayInSeconds)
                        }
                    }
                    
                    let newNotifyTime = self.timePicker.date.addingTimeInterval(Common.dayInSeconds)
                    
                    //TODO if the next time is greater than 24 hours, warn the user
                    
                    self.userRef!.child("Time").setValue(newNotifyTime.timeIntervalSince1970)
                    
                    //if there already isn't an old notification time set
                    if oldTime == nil {
                        self.userRef!.child("Old_Time").setValue(currNotifyTime.timeIntervalSince1970)
                    }
                    
                    self.timeLabelDelegate?.updateTimeLabel(newDate: newNotifyTime)
                    
                    self.timeField.text = self.dateFormatter.string(from: newNotifyTime)
                })
            })
            super.onClose(sender)
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

