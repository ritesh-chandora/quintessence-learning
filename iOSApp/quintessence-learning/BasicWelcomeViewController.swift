//
//  BasicWelcomeViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 8/10/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class BasicWelcomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let timePicker = UIDatePicker()
    let dayPicker = UIPickerView()
    var dayPickerIndex = 0
    let dayPickerData = ["Monday",
                         "Tuesday",
                         "Wednesday",
                         "Thursday",
                         "Friday"]
    var timePicked = false
    var dayPicked = false
    var ref:DatabaseReference?
    
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var dayField: UITextField!
    
    
    @IBAction func setTimeButton(_ sender: UIButton) {
        if (timePicked && dayPicked){
            Common.timeInterval = Common.weekInSeconds
            let userView = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
            
            //set the new time to be at the designed weekday every week
            let calendar = Calendar.current
            let comp = calendar.dateComponents([.timeZone, .year, .weekOfYear, .hour, .minute], from: timePicker.date)
            var components = DateComponents()
            components.hour = comp.hour
            components.minute = comp.minute
            components.weekday = dayPickerIndex + 2
            components.weekOfYear = comp.weekOfYear!
            components.year = comp.year
            components.timeZone = comp.timeZone!
            
            Common.dayOfWeek = dayPickerIndex + 2
            
            let newTime = Calendar.current.date(from: components)
            self.ref!.child("Time").setValue(newTime?.timeIntervalSince1970)
            
            Common.setNotificationTimer(date: newTime!, repeating: true, daily: false)
            //initialize the account to be a user and initializes the time
            ref!.child("Type").setValue("basic")
            self.present(userView, animated: true)
        } else {
            Server.showError(message: "Please set both!")
        }
    }
    
    //picker view data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dayPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dayPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateLabel()
    }
    
    func updateLabel(){
        dayField.text = dayPickerData[dayPicker.selectedRow(inComponent: 0)]
        dayPickerIndex = dayPicker.selectedRow(inComponent: 0)
    }
    
    //initializes the time picker to be shown upon tapping the text field
    func createPicker(){
        timePicker.datePickerMode = .time
        dayPicker.dataSource = self
        dayPicker.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(timeDonePressed))
        toolbar.setItems([doneButton], animated: false)
        
        let dayToolbar = UIToolbar()
        dayToolbar.sizeToFit()
        
        let dayDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dayDonePressed))
        dayToolbar.setItems([dayDoneButton], animated: false)
        
        timeField.inputAccessoryView = toolbar
        timeField.inputView = timePicker
        
        dayField.inputAccessoryView = dayToolbar
        dayField.inputView = dayPicker
    }
    
    //handler for dayPicker done being pressed
    func dayDonePressed(){
        updateLabel()
        self.view.endEditing(true)
        dayPicked = true
    }
    
    //handler for timePicker done being pressed
    func timeDonePressed(){
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        timeField.text = dateFormatter.string(from: timePicker.date)
        self.view.endEditing(true)
        timePicked = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid)
        createPicker()
    }

}
