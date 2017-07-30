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
    
//    static let dayInSeconds:Double = 30
    static let dayInSeconds:Double = 86400
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
    static func setNotificationTimer(date:Date){
        var dateComponents = DateComponents()
        let components = getHourAndMinutes(date: date)
        dateComponents.hour = components[0]
        dateComponents.minute = components[1]
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "New Question Today!"
        notificationContent.body = "Swipe to open question..."
        notificationContent.categoryIdentifier = "alarm"
        notificationContent.userInfo = ["wtf":"???"]
        notificationContent.sound = UNNotificationSound.default()
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        print("notification timer set!")
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
        return [hour, minutes]
    }
}
