//
//  QuestionViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/24/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseAuth
import FirebaseDatabase
import TagListView
//import UserNotifications
class QuestionViewController: UIViewController {

    var notifyTime:Date?
    var timer:Timer? {
        willSet {
            timer?.invalidate()
        }
    }
    var user:User?
    var ref:DatabaseReference?
    var currentQuestionKey = ""
    
    @IBOutlet weak var questionLabel: UITextView!
    @IBOutlet weak var tagsList: TagListView!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    //check for expiry of either premium or of trial
    func showPremiumScreen() {
        ref!.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let type = value?["Type"] as? String ?? ""
            if (type == "premium") {
                if (!SubscriptionService.shared.hasReceiptData!) {
                    //show premium screen if not
                    print("why")
                    let premiumScreen = self.storyboard?.instantiateViewController(withIdentifier: "Premium") as! PremiumPurchaseViewController
                    self.present(premiumScreen, animated: true)
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
                }
            }
        })
    }
    
    //destroy timer if view is left
    override func viewWillDisappear(_ animated: Bool) {
        invalidateTimer()
    }
    
    //checks to see if new question has to be loaded and then loads a timer in case user stays on that screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        //check if expired
        self.showPremiumScreen()
        
        print ("view will appear!")
        //if there was a temporary time, load that first and set that to the notifyTime
        ref!.child("Old_Time").observeSingleEvent(of: .value, with: { (data) in
            let oldTime = data.value as? TimeInterval ?? nil
            if oldTime != nil {
                self.notifyTime = Date(timeIntervalSince1970: oldTime!)
                self.checkIfNeedUpdate()
            } else {
                //if no temporary time (see NewTimeVC), then query the standard time
                self.ref!.child("Time").observeSingleEvent(of: .value, with: { (time) in
                    self.notifyTime = Date(timeIntervalSince1970: time.value as! TimeInterval)
                    self.checkIfNeedUpdate()
                })
            }

        })
        
        var displayString = "Current Pending Notifications "
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            (requests) in
            displayString += "count:\(requests.count)\t"
            for request in requests{
                print(request)
                displayString += request.identifier + "\t"
            }
            print(displayString)
        }
        print(Common.timeInterval)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //listener for when app enters background to invalidate timer
        NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkIfNeedUpdate), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        user = Auth.auth().currentUser!
        ref = Database.database().reference().child(Common.USER_PATH).child(user!.uid)
        
        getQuestion()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(showSaveOptions))
    }
    
    func invalidateTimer(){
        if timer != nil {
            debugPrint("timer invalidated!")
            timer?.invalidate()
            timer = nil
        }
    }
    
    //checks to see if update is needed
    func checkIfNeedUpdate(){
        
        //query both old time (if any) and the current notification time
        ref!.child("Old_Time").observeSingleEvent(of: .value, with: { (data) in
            self.ref!.child("Time").observeSingleEvent(of: .value, with: { (time) in
                var oldTime = data.value as? TimeInterval ?? nil
                
                //if old time exists, that is the next notification time
                if oldTime != nil {
                    self.notifyTime = Date(timeIntervalSince1970: oldTime!)
                } else {
                    //if no temporary time (see NewTimeVC), then query the standard time
                   self.notifyTime = Date(timeIntervalSince1970: time.value as! TimeInterval)
                }
                
                let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let components = calendar.dateComponents([.weekday], from: Date())
                //multiplier is needed because with old_time daysMissed will be off by one
                var multiplier = 0
                var daysMissed = 0
                
                //if it is friday thru sunday, don't notify and add appropriate time to next question
                if (Common.weekend.contains(components.weekday!) && Common.timeInterval == Common.dayInSeconds) {
                    if(components.weekday == 6) {
                        //friday, add 3 days to it
                        multiplier+=3
                    } else if (components.weekday == 7){
                        //saturday, add 2 days
                        multiplier+=2
                    } else if (components.weekday == 1) {
                        //sunday, add one day
                        multiplier+=1
                    }
                    self.notifyTime!.addTimeInterval(Common.dayInSeconds*Double(multiplier))
                    self.ref!.child("Time").setValue(self.notifyTime?.timeIntervalSince1970)
                } else {
                
                    let currTime = Date()
                    
                    var timeElapsed = currTime.timeIntervalSinceReferenceDate - self.notifyTime!.timeIntervalSinceReferenceDate
                    
                    debugPrint(timeElapsed)
                    print(self.notifyTime!)
                    //if the time has passed since notification date
                        if (timeElapsed >= 0) {
                        
                        //Handle case if user changed time and then didn't check until after next notification
                        if (oldTime != nil) {
                            let newNotifyTime = Date(timeIntervalSince1970: time.value as! TimeInterval)
                            let oldTimeElapsed = newNotifyTime.timeIntervalSinceReferenceDate - self.notifyTime!.timeIntervalSinceReferenceDate
                            //if time has elapsed between old notify time and new notify time, that will count as one day missed
                            if (timeElapsed > oldTimeElapsed){
                                daysMissed += 1
                            }
                            print("old time elapsed: \(timeElapsed)")
                            timeElapsed -= oldTimeElapsed
                            print("new time elapsed: \(timeElapsed)")
                            self.notifyTime! = newNotifyTime
                            print("why\(newNotifyTime)")
                            self.ref!.child("Old_Time").setValue(nil)
                            oldTime = nil
                        }
                        //check for missed days and if so, add those questions to saved questions
                        daysMissed += Int(timeElapsed/Common.timeInterval)
                        multiplier += Int(timeElapsed/Common.timeInterval)
                        if (daysMissed > 0){
                            print("\(daysMissed) days missed")
                            self.saveMissedQuestions(days: daysMissed)
                        }
                        
                        
                        //increment the user count
                        multiplier+=1
                        daysMissed+=1
                        
                        //set next question update to next day
                        self.notifyTime!.addTimeInterval(Common.timeInterval*Double(multiplier))
                        print("new tiem \(self.notifyTime!) in seconds: \(self.notifyTime!.timeIntervalSince1970)")
                        if(oldTime != nil){
                            self.ref!.child("Old_Time").setValue(self.notifyTime?.timeIntervalSince1970)
                        } else {
                            self.ref!.child("Time").setValue(self.notifyTime?.timeIntervalSince1970)
                        }
                    }
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                //update with next notification time
                DispatchQueue.main.async {
                    self.timeLabel.text! = dateFormatter.string(from: self.notifyTime!)
                }
                
                self.invalidateTimer()
                self.setNextQuestionTimer()
                self.setQuestionCount(days: daysMissed)
            })
        })
    }
    func setTimer(){
        print("current time: \(Date().timeIntervalSinceReferenceDate), fire time: \(timer!.fireDate.timeIntervalSinceReferenceDate)")
        if (Int(Date().timeIntervalSinceReferenceDate) <= Int(timer!.fireDate.timeIntervalSinceReferenceDate)) {
            print("jej")
            checkIfNeedUpdate()
        }
    }
    //sets a timer to retrieve next question if user leaves this view controller running
    func setNextQuestionTimer(){
        //invalid previous timer, if any
        if timer == nil {
            print("timer set for \(notifyTime!)")
            timer = Timer(fireAt: notifyTime!, interval: 0, target: self, selector: #selector(setTimer), userInfo: nil, repeats: false)
            RunLoop.main.add(timer!, forMode: .commonModes)
        }
    }
    
    //gets the next question by incrementing this user's count by the number of days elapsed since last check
    func setQuestionCount(days:Int) {
        self.ref!.child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            self.ref!.child(Common.USER_COUNT).setValue(value+days)
            self.getQuestion()
        })
    }

    //retrieves a question according to this user's count
    func getQuestion(){
        self.questionLabel.text = ""
        //get the count

        self.ref!.child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            //get the first question greater than or equal to count
            Database.database().reference().child(Common.QUESTION_PATH).queryOrdered(byChild: "count").queryStarting(atValue: value).queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: {(snapshot) in
                
                //this is needed here because it gets tags twice for some reason
                self.tagsList.removeAllTags()
                let result = snapshot.children.allObjects as! [DataSnapshot]
                if (result.count == 0) {
                    self.questionLabel.text = "Unable to load question"
                } else {
                    let qbody = result[0].value as? NSDictionary
                    if let qbody = qbody {
                        self.questionLabel.text = qbody["Text"] as? String ?? "Unable to load question"
                        self.currentQuestionKey = qbody["Key"] as? String ?? ""
                        if let tags = qbody["Tags"] as? NSDictionary {
                            for (_, tag) in tags {
                                self.tagsList.addTag(tag as? String ?? "")
                            }
                        }
                    } else {
                        self.questionLabel.text = "Unable to load question"
                    }
                }
            })
        }) { (err) in
            debugPrint(err)
        }
    }
 
    //saves a question with the given key
    func saveQuestion(key:String, showError:Bool){
        self.ref!.child("Saved").queryOrderedByKey().queryEqual(toValue: key).observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.exists()
            if(data){
                if (showError) {
                    Server.showError(message: "Already saved this question!")
                }
            } else {
                self.ref!.child("Saved").updateChildValues([key:true])
                
                if (showError) {
                    DispatchQueue.main.async {
                        let animatationDuration = 0.5
                        UIView.animate(withDuration: animatationDuration, animations: { () -> Void in
                            self.savedLabel.alpha = 1
                        }) { (Bool) -> Void in
                            UIView.animate(withDuration: animatationDuration, delay: 2.0, options: .curveEaseInOut, animations: {
                                self.savedLabel.alpha = 0
                            }, completion: nil)
                        }
                    }
                }
            }
        })
    }
    
    //saves each question that was missed
    func saveMissedQuestions(days:Int){
        self.ref!.child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            print("question from \(value) to \(days) after")
            //get the first question greater than or equal to count
            Database.database().reference().child(Common.QUESTION_PATH).queryOrdered(byChild: "count").queryStarting(atValue: value+1).queryLimited(toFirst: UInt(days)).observeSingleEvent(of: .value, with: {(snapshot) in
                let result = snapshot.children.allObjects as! [DataSnapshot]
                if (result.count == 0) {
                    self.questionLabel.text = "Unable to load question"
                }
                print(result)
                for qbody in result {
                    let qdata = qbody.value as? NSDictionary
                    if let qdata = qdata {
                        if let key = qdata["Key"] as? String {
                            self.saveQuestion(key: key, showError: false)
                        }
                    }
                }
            })
        }) { (err) in
            debugPrint(err)
        }
    }
    
    //shows the save actionSheet
    func showSaveOptions(){
        let ac = UIAlertController(title: "Question Options", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Save this question", style: .default, handler: { (action) in
            self.saveQuestion(key: self.currentQuestionKey, showError: true)
        }))
        
        ac.addAction(UIAlertAction(title: "View all saved questions", style: .default, handler: { (action:UIAlertAction ) in
            let savedView = self.storyboard?.instantiateViewController(withIdentifier: "SavedQ") as! SavedTableViewController
            self.navigationController?.pushViewController(savedView, animated: true)
        }))
        
        ac.addAction(UIAlertAction(title: "View all past questions", style: .default, handler: { (action) in
            let pastView = self.storyboard?.instantiateViewController(withIdentifier: "Past") as! PastQuestionsTableViewController
            self.navigationController?.pushViewController(pastView, animated: true)
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(ac, animated: true)
    }
}
