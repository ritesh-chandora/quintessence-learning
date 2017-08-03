//
//  Constants.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/28/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import UserNotifications
class Common: NSObject {
    
    static let dayInSeconds:Double = 120
//    static let dayInSeconds:Double = 86400
    static let trialLength = 14
    static let USER_PATH = "Users"
    static let QUESTION_PATH = "Questions"
    static let USER_COUNT = "Current_Question"
    
    static func showSuccess(message:String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: message, message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindowLevelAlert + 1;
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(ac, animated: true, completion: nil)
        }
    }
    
    //sets the notification timer
    static func setNotificationTimer(date:Date, repeating:Bool){
        var dateComponents = DateComponents()
        let components = getHourAndMinutes(date: date)
        dateComponents.hour = components[0]
        dateComponents.minute = components[1]
        dateComponents.second = components[2]
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "New Question Today!"
        notificationContent.body = "Swipe to open question..."
        notificationContent.categoryIdentifier = "alarm"
        notificationContent.userInfo = ["wtf":"???"]
        notificationContent.sound = UNNotificationSound.default()
        
        //if repeating, repeat for every weekday
        if(repeating){
            for day in 2 ..< 7{
                
                dateComponents.weekday = day
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeating)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        } else {
            debugPrint("set for \(dateComponents)")
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeating)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
        debugPrint("notification timer set!")
    }
    
    //determines if the time selected to notify is later than current, and if so, 24 hr delay must be implemented
    static func isTimeLater(date:Date) -> Bool {
        let notify = getHourAndMinutes(date: date)
        let current = getHourAndMinutes(date: Date())
        if (notify[0] < current[0]){
            return false
        }
        if (notify[0] == current[0]) {
            if (notify[1] < current[1]) {
                return false
            }
            else {
                return true
            }
        }
        return true
    }
    
    //helper method for isNotifyTimeLater
    static func getHourAndMinutes(date:Date) -> [Int] {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return [hour, minutes, seconds]
    }
}
