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
import Foundation
protocol UpdateTimeLabel {
    func updateTimeLabel(newDate:Date) -> Void
}


class NewTimeViewController: ModalViewController {
    
    var timePicker = UIDatePicker()
    
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var notifyMon: UISwitch!
    @IBOutlet weak var notifyTue: UISwitch!
    @IBOutlet weak var notifyWed: UISwitch!
    @IBOutlet weak var notifyThu: UISwitch!
    @IBOutlet weak var notifyFri: UISwitch!
    @IBOutlet weak var notifySat: UISwitch!
    @IBOutlet weak var notifySun: UISwitch!
    
    func checkIfSwichAllowed(sender:UISwitch) -> Void {
        if sender.isOn == true{
            let notifyArr =  getNotifyWeekdaySwitchInUI()
            var allowedDaysCnt = 0
            
            for day in notifyArr {
                if day == 1{
                    allowedDaysCnt = allowedDaysCnt + 1
                }
            }
            
            if(allowedDaysCnt > Common.daysAllowedForPaidSubs ){
                let dialog = UIAlertController(title: "Message", message: "You can select 5 days a week only.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in sender.setOn(false, animated: true)
                })
                dialog.addAction(ok)
                self.present(dialog,animated: true,completion: nil)
            }
            else{
                timePicked = true
            }
        }
        if sender.isOn == false{
            let notifyArr =  getNotifyWeekdaySwitchInUI()
            var allowedDaysCnt = 0
            
            for day in notifyArr {
                if day == 1{
                    allowedDaysCnt = allowedDaysCnt + 1
                }
            }
            
            if(allowedDaysCnt < 1 ){ // mimimum one day should be selected
                let dialog = UIAlertController(title: "Message", message: "You need to select at least one day.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in sender.setOn(true, animated: true)
                })
                dialog.addAction(ok)
                self.present(dialog,animated: true,completion: nil)
            }
            else{
                timePicked = true
            }
            
        }
        
    }
 
    @IBAction func onChangeNotifyMon(_ sender: UISwitch) {
        checkIfSwichAllowed(sender: sender)
    }
    
    @IBAction func onChangeNotifyTue(_ sender: UISwitch) {
        checkIfSwichAllowed(sender: sender)
    }
    
    @IBAction func onChangeNotifyWed(_ sender: UISwitch) {
        checkIfSwichAllowed(sender: sender)
    }
    
    @IBAction func onChangeNotifyThu(_ sender: UISwitch) {
        checkIfSwichAllowed(sender: sender)
    }
    
    @IBAction func onChangeNotifyFri(_ sender: UISwitch) {
        checkIfSwichAllowed(sender: sender)
    }
    
    @IBAction func onChangeNotifySat(_ sender: UISwitch) {
        checkIfSwichAllowed(sender: sender)
    }
    
    @IBAction func onChangeNotifySun(_ sender: UISwitch) {
        checkIfSwichAllowed(sender: sender)
    }
    
    var timePicked = false
    let dateFormatter = DateFormatter()
    var userRef:DatabaseReference?
    var timeLabelDelegate:UpdateTimeLabel?
    
    @IBAction override func onClose(_ sender: UIButton) {
        super.onClose(sender)
    }
    
    @IBAction func onSubmit(_ sender: UIButton) {
        //Things to consider
        // user can only change time for next day. Today day or notification will not be affected.
        if (timePicked) {
            userRef!.observeSingleEvent(of: .value, with: { (snapshot) in
                let userInfo = snapshot.value as? NSDictionary
                if let userInfo = userInfo {
                    //keep old time for one cycle, then update to the new time
                    let userNotifyTime = userInfo["Time"] as! TimeInterval
                    let userNotifyTime_Date = Date(timeIntervalSince1970: userNotifyTime)
                    var userNotifyOldTime:TimeInterval?
                    let userNotifyDays:String
                    var userNotifyOldDays:String?
                    
                    if userInfo["Old_Time"] != nil{
                        userNotifyOldTime = userInfo["Old_Time"] as? TimeInterval ?? nil
                        //let userNotifyOldTime_Date = Date(timeIntervalSince1970: userNotifyOldTime)
                    }
                    else{
                        userNotifyOldTime = nil
                    }
                    
                    if userInfo["NotificationDays"] != nil {
                        userNotifyDays = userInfo["NotificationDays"] as! String
                    }
                    else{
                        userNotifyDays = ""
                    }
                    
                    if userInfo["Old_NotificationDays"] != nil {
                        userNotifyOldDays = userInfo["Old_NotificationDays"] as? String ?? nil
                    }
                    else {
                        userNotifyOldDays = nil
                    }
                    
                    //var notifyTime:TimeInterval
                    var notifyDays:[Int]
                    if userNotifyOldDays != nil {
                        //notifyTime = userNotifyOldTime!
                        notifyDays = userNotifyOldDays!.components(separatedBy: ",").map({ (x:String) -> Int in return Int(x)! })
                    }
                    else{
                        //notifyTime = userNotifyTime
                        notifyDays = userNotifyDays.components(separatedBy: ",").map({ (x:String) -> Int in return Int(x)! })
                    }
                    
                    //offset new time with weekend, if needed
                    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let components = calendar.dateComponents([.weekday], from:Date.init() )
                    
                    var newNotifyTime = self.timePicker.date
                    debugPrint("Notification time selected from Date Picket \(newNotifyTime)")
                    
                    
                //This calculation is only for Days.
                    //Now we are going to add very complex logic
                    //Check today date and count how much question user got.
                    // Now count how many questios are remaining.
                    //if remaing question are matching the old pattern then no issue. Else set notification to next week.
                    let todayWeekDay = components.weekday! - 1 //Subtract one because sunday start from 1 in Component and 0 in our Array
                    var totalDaysQuesReceived = 0
                    var totalQuesWillReceivedByNewDays = 0
                    for day in 0...todayWeekDay {
                        if notifyDays[day] == 1 {
                            totalDaysQuesReceived+=1
                        }
                    }
                    let newNotifyDays = self.getNotifyWeekdaySwitchInUI()
                    for day in (todayWeekDay+1)..<7 {
                        if newNotifyDays[day] == 1 {
                            totalQuesWillReceivedByNewDays+=1
                        }
                    }
                    print("Total totalDaysQuesReceived \(totalDaysQuesReceived)  totalQuesWillReceivedByNewDays\(totalQuesWillReceivedByNewDays)")
                    
                    //if remaing question count of week is less then equal then the question he is going to recive then there should be no issue.
                    if( (Common.daysAllowedForPaidSubs - totalDaysQuesReceived) >= totalQuesWillReceivedByNewDays) {
                        //allowed so delete the Old values and update it with new one.
                        
                        //check when can you notify for next notification.
                        var tempWeekDayHolder = todayWeekDay+1 // start from next working day
                        tempWeekDayHolder%=7 // In the case of overflow
                        var multiplier = 1
                        
                        while(newNotifyDays[tempWeekDayHolder] == 0){
                            multiplier+=1
                            tempWeekDayHolder+=1 //Add one day
                            tempWeekDayHolder%=7 // Reset to Sunday if exceed
                            print("In Loop allowed days forward tempWeekDayHolder \(tempWeekDayHolder)  multiplier \(multiplier)")
                        }
                        print("multipler for remaing questions   \(multiplier)")
                        
                        //set next question update to next day
                        newNotifyTime.addTimeInterval(Common.timeInterval*Double(multiplier))
                        print("notification time set to  after \(newNotifyTime)")
                    }
                    else {
                        //Not allowed. Here user got more question then he supposed to get, if we apply newNotification immediatly. So we will iterate through new Notificaction day in reverse order and confirm when to provide new notification.
                        
                        print("Not allowed so else check in backward direction.")
                        var remainingQuestionCount = (Common.daysAllowedForPaidSubs - totalDaysQuesReceived)
                        
                        let todayWeekDay = components.weekday! - 1 //Subtract one because sunday start from 1 in Component and 0 in our Array
                        
                        var tempWeekDayHolder = todayWeekDay+1 // start from next working day
                        tempWeekDayHolder%=7 // In the case of overflow
                        var multiplier = 1
                        
                        var loopWeekItr = Common.weekDays.count - 1 // count is 7 but array size is 6
                        while(loopWeekItr > 0){ // loop will iterate for 7 times
                            print("In Loop Reamaing question \(remainingQuestionCount)  \(loopWeekItr)")
                            if remainingQuestionCount < 1 {
                                break
                            }
                            if newNotifyDays[loopWeekItr] == 1 {
                                remainingQuestionCount-=1
                            }
                            loopWeekItr-=1 // reduce
                        }
                        print("the day when we can provide next notification ZZ\(loopWeekItr)")
                        
                        //Now check if next notification is current day or previous day. Then set new notification to next day. Else add the day and set next notification time accordingly
                        if loopWeekItr > todayWeekDay {
                            print("Days is forward to Current working day")
                            multiplier = loopWeekItr - loopWeekItr
                            newNotifyTime.addTimeInterval(Common.timeInterval*Double(multiplier))
                        }
                        else{
                            print("Days is backward to Current working day")
                            //check when can you notify for next notification.
                            var tempWeekDayHolder = todayWeekDay+1 // start from next working day
                            var multiplier = 1
                            
                            while(newNotifyDays[tempWeekDayHolder] == 0){
                                multiplier+=1
                                tempWeekDayHolder+=1 //Add one day
                                tempWeekDayHolder%=7 // Reset to Sunday if exceed
                                print("In Loop XX \(tempWeekDayHolder)  \(multiplier)")
                            }
                            print("multipler XX\(multiplier)")
                            
                            //set next question update to next day
                            newNotifyTime.addTimeInterval(Common.timeInterval*Double(multiplier))
                        }
                        
                        //cancel all pending notifications
//                        let center = UNUserNotificationCenter.current()
//                        center.removeAllPendingNotificationRequests()
                        //set new notification timer
                        //Common.setNotificationTimer(date: newNotifyTime, repeating: true, daily: true)
                        
                        //Common.setNotificationTimer(date: newNotifyTime, repeatingDays: )
                       
                    }
                    
                    //set the new notification
                    print("ZZZ new tiem \(newNotifyTime) in seconds: \(newNotifyTime.timeIntervalSince1970)")
                    
                    /////////////////////////////
                    //Need to check if this newTime is valid to be notification
                    
//                    var temp_isValidNotifyWeekHolder = Calendar(identifier: Calendar.Identifier.gregorian).dateComponents([.weekday], from: newNotifyTime).weekday! - 1
//                    var daysToBeSkipped = 0
//                    if (newNotifyDays[temp_isValidNotifyWeekHolder] == 0  && Common.timeInterval == Common.dayInSeconds) {
//                        while(newNotifyDays[temp_isValidNotifyWeekHolder] == 0){
//                            daysToBeSkipped+=1
//                            temp_isValidNotifyWeekHolder+=1 //Add one day
//                            temp_isValidNotifyWeekHolder%=7 // Reset to Sunday if exceed
//                            print("In Loop \(temp_isValidNotifyWeekHolder)  \(daysToBeSkipped)")
//                        }
//                    }
//
//                    //set next question update to next day
//                    newNotifyTime.addTimeInterval(Common.timeInterval*Double(daysToBeSkipped))
//                    print("Rechecked time for  new tiem \(newNotifyTime) in seconds: \(newNotifyTime.timeIntervalSince1970)")
                    
                    self.userRef!.child("Time").setValue(newNotifyTime.timeIntervalSince1970)
                    
                    
                    //cancel all pending notifications
//                    let center = UNUserNotificationCenter.current()
//                    center.removeAllPendingNotificationRequests()
                    //set new notification timer
//                    Common.setNotificationTimer(date: newNotifyTime, repeating: true, daily: true)
                    
                    if userNotifyOldTime != nil {
                        print("(if Exist)=previous Old tiem \(userNotifyOldTime!) in seconds: \(userNotifyOldTime!)")
                    }
                    print("=previous New tiem \(userNotifyTime) in seconds: \(userNotifyTime)")
                    print("=new tiem \(newNotifyTime) in seconds: \(newNotifyTime.timeIntervalSince1970)")
                    
                    
                    //Set the new notification with current Notification days
                    self.userRef!.child("NotificationDays").setValue(newNotifyDays.map(String.init).joined(separator: ","))
                    
                    //cancel all pending notifications
                    let center = UNUserNotificationCenter.current()
                    center.removeAllPendingNotificationRequests()
                    //set new notification timer
                    Common.setNotificationTimer(date: newNotifyTime, isRepeating:true, repeatingDays: newNotifyDays)
                    
                    
                    //if there already isn't an old notification time set
                    //If old Notification days are not there then update for bookkeeping
                    if userNotifyOldTime == nil {
                        if userNotifyTime_Date.timeIntervalSince1970 > newNotifyTime.timeIntervalSince1970 {
                            print("user old time \(userNotifyTime_Date.timeIntervalSince1970) is bigger then new time \(newNotifyTime.timeIntervalSince1970) so we are reseting the old notification.")
                            self.userRef!.child("Old_Time").setValue(nil)
                            self.userRef!.child("Old_NotificationDays").setValue(nil)
                        }
                        else {
                            
                            /////////////////////////////
                            //Need to check if this oldTime is valid to be notified
                            //Here we have twist. What if user got today notification then changing to something
                            
//                            let temp_isValidNotifyWeekHolder = Calendar(identifier: Calendar.Identifier.gregorian).dateComponents([.weekday], from: userNotifyTime_Date).weekday! - 1
//
//                            if (newNotifyDays[temp_isValidNotifyWeekHolder] == 1 ) {
                                self.userRef!.child("Old_NotificationDays").setValue(userNotifyDays)
                                self.userRef!.child("Old_Time").setValue(userNotifyTime_Date.timeIntervalSince1970)
                                //set one notification timer for this last notification at that time
                                Common.setNotificationTimer(date: userNotifyTime_Date, isRepeating: false , repeatingDays: nil)                          
                                
//                            }
                        }
                    }
                    else{
                        //If Old_Time is bigger than new_Time, Then we dont need the old time anymore.
                        if userNotifyTime_Date.timeIntervalSince1970 > newNotifyTime.timeIntervalSince1970 {
                            print("user old time \(userNotifyTime_Date.timeIntervalSince1970) is bigger then new time \(newNotifyTime.timeIntervalSince1970) so we are reseting the old notification.")
                            self.userRef!.child("Old_Time").setValue(nil)
                            self.userRef!.child("Old_NotificationDays").setValue(nil)
                        }
                    }
                    
                    //update the label on ProfileViewController
                    self.timeLabelDelegate?.updateTimeLabel(newDate: newNotifyTime)
                    Common.showSuccess(message: "Warning: Notifications may take up to 24 hours to take effect!")
                    self.timeField.text = self.dateFormatter.string(from: newNotifyTime)
                    
                    
                }
            })
        }
        super.onClose(sender)
    }

    
    override func viewDidLoad() {
        createPicker()
        
        dateFormatter.timeStyle = .short
        
        userRef = Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid)
        
        //set the current notification date label
        userRef!.child("Time").observeSingleEvent(of: .value, with: { (time) in
            self.timeLabel.text! = self.dateFormatter.string(from: Date(timeIntervalSince1970: time.value as! TimeInterval))
            self.timeField.text = self.dateFormatter.string(from: self.timePicker.date)
        })
        
        //set the current notification date label
        userRef!.child("NotificationDays").observeSingleEvent(of: .value, with: { (snapshot) in
            let snap = snapshot.value as! String
            self.setNotifyWeekdaySwitchInUI(snap.components(separatedBy: ",").map({ (x:String) -> Int in return Int(x)! }) )
        });
        
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
    
    func setNotifyWeekdaySwitchInUI(_ weekdaysNotifyArr:[Int]){
        for (day,val) in weekdaysNotifyArr.enumerated() {
            switch Common.weekDays[day] {
            case "Monday" :
                notifyMon.setOn((val != 0), animated: false)
            case "Tuesday" :
                notifyTue.setOn((val != 0), animated: false)
            case "Wednesday" :
                notifyWed.setOn((val != 0), animated: false)
            case "Thursday" :
                notifyThu.setOn((val != 0), animated: false)
            case "Friday" :
                notifyFri.setOn((val != 0), animated: false)
            case "Saturday" :
                notifySat.setOn((val != 0), animated: false)
            case "Sunday" :
                notifySun.setOn((val != 0), animated: false)
            default:
                print("setNotifyWeekdaySwitchInUI Something went wrong.")
            }
        }
    }
    
    func getNotifyWeekdaySwitchInUI() -> [Int] {
        var weekdaysNotifyArr = [0,0,0,0,0,0,0]
        for day in 0..<Common.weekDays.count {
            switch Common.weekDays[day] {
            case "Monday":
                weekdaysNotifyArr[day] = notifyMon.isOn == true ? 1 : 0
            case "Tuesday":
                weekdaysNotifyArr[day] = notifyTue.isOn == true ? 1 : 0
            case "Wednesday":
                weekdaysNotifyArr[day] = notifyWed.isOn == true ? 1 : 0
            case "Thursday":
                weekdaysNotifyArr[day] = notifyThu.isOn == true ? 1 : 0
            case "Friday":
                weekdaysNotifyArr[day] = notifyFri.isOn == true ? 1 : 0
            case "Saturday":
                weekdaysNotifyArr[day] = notifySat.isOn == true ? 1 : 0
            case "Sunday":
                weekdaysNotifyArr[day] = notifySun.isOn == true ? 1 : 0
            default:
                print("setNotifyWeekdaySwitchInUI Something went wrong.")
                break
            }
        }
        return weekdaysNotifyArr
    }
}

