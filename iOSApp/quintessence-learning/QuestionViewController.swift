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
class QuestionViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var howToUseFamilyHuddles: UILabel!
    @IBOutlet weak var FaqsAndCommon: UILabel!
    @IBOutlet weak var whyGetFamilyPremium: UILabel!
    @IBOutlet weak var savedQuestionAndFav: UILabel!
    
    @IBOutlet weak var showQuestionTable: UITableView!
    var QuestionsFromServer: [String] = ["","","","","",""]
    var bQuestionsFromServerFetched = false;
    
    var notifyTime:Date?
    var timer:Timer? {
        willSet {
            timer?.invalidate()
        }
    }
    var notifyDay:[Int]?
    
    var user:User?
    var ref:DatabaseReference?
    var currentQuestionKey = [String]()
    
    //@IBOutlet weak var savedLabel: UILabel!
    //@IBOutlet weak var timeLabel: UILabel!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if QuestionsFromServer[0] != "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! questionCell
            cell.selectionStyle = .none;
            if (indexPath.row % 2) == 0 {
                cell.questionHolder.text = " ● "+QuestionsFromServer[indexPath.row]
                cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
                NSLayoutConstraint.activate([
                    cell.questionHolder.widthAnchor.constraint(equalToConstant: cell.frame.width) ,
                    cell.questionHolder.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -15) ])
            }
            else {
                cell.questionHolder.text = "  "+QuestionsFromServer[indexPath.row]+"  "
                cell.questionHolder.backgroundColor = UIColor(red: 239/255, green: 166/255, blue: 77/255, alpha: 1)
                NSLayoutConstraint.activate([
                    cell.questionHolder.heightAnchor.constraint(equalToConstant: 26)])
                cell.questionHolder.font = UIFont.systemFont(ofSize: 13)
            }
            return cell
        }
        else {
            let cell = UITableViewCell()
            cell.textLabel!.text = "loading..."
            return cell
        }
    }
    
    func checkPremium(){
        if (!SubscriptionService.shared.hasReceiptData!) {
            //show premium screen if not
            let premiumScreen = self.storyboard?.instantiateViewController(withIdentifier: "Premium") as! PremiumPurchaseViewController
            self.present(premiumScreen, animated: true)
            return
        }
    }
    
    //check for expiry of either premium or of trial
    func showPremiumScreen() {
        ref!.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let type = value?["Type"] as? String ?? ""
            if (type == "premium") {
                DispatchQueue.main.async {
                    let premiumTimer = Timer(timeInterval: 10, target: self, selector: #selector(self.checkPremium), userInfo: nil, repeats: false)
                    RunLoop.main.add(premiumTimer, forMode: .commonModes)
                }
            }
            else if (type == "premium_trial") {
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
 
        //check if user has reinstalled the app, where notification permissions have been cleared
        if (!UserDefaults.standard.bool(forKey: "AskedForNotifications")) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                if granted {
                    UserDefaults.standard.set(true, forKey: "AskedForNotifications")
                    Common.showSuccess(message: "Warning: First notification may be off by 24 hours!")
                } else {
                    print(" Question view User did not provide the required permission to show notificaiton")
                }
            }
        }
        
        //listener for when app enters background to invalidate timer
        NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimer), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkIfNeedUpdate), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        user = Auth.auth().currentUser!
        ref = Database.database().reference().child(Common.USER_PATH).child(user!.uid)
        
        let tapActionHowToUseFamily = UITapGestureRecognizer(target: self, action: #selector(self.howToUseFamilyHuddlesActionTapped(_:)))
        howToUseFamilyHuddles?.addGestureRecognizer(tapActionHowToUseFamily)
        
        let tapActionFaqAndCommon = UITapGestureRecognizer(target: self, action: #selector(self.FaqsAndCommonActionTapped(_:)))
        FaqsAndCommon?.addGestureRecognizer(tapActionFaqAndCommon)
        
        let tapActionWhyGetFamilyPremium = UITapGestureRecognizer(target: self, action: #selector(self.whyGetFamilyPremiumActionTapped(_:)))
        whyGetFamilyPremium?.addGestureRecognizer(tapActionWhyGetFamilyPremium)
        
        let tapActionSavedQuestionAndFav = UITapGestureRecognizer(target: self, action: #selector(self.savedQuestionAndFavActionTapped(_:)))
        savedQuestionAndFav?.addGestureRecognizer(tapActionSavedQuestionAndFav)
        
        getQuestion()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(showSaveOptions))
    }
    
    func howToUseFamilyHuddlesActionTapped(_ sender: UITapGestureRecognizer){
        print("Yes tap works")
    }
    
    func FaqsAndCommonActionTapped(_ sender: UITapGestureRecognizer){
        let FAQ = FAQViewController()
        self.navigationController?.pushViewController(FAQ, animated: true)
    }
    
    func whyGetFamilyPremiumActionTapped(_ sender: UITapGestureRecognizer){
        let PremiumFAQ = PremiumFAQViewController()
        self.navigationController?.pushViewController(PremiumFAQ, animated: true)
    }
    func savedQuestionAndFavActionTapped(_ sender: UITapGestureRecognizer){        showSaveOptions()
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
        ref!.observeSingleEvent(of: .value, with: { (snapshot) in
            let userInfo = snapshot.value as? NSDictionary
            if let userInfo = userInfo {
                let userNotifyTime = userInfo["Time"] as! TimeInterval
                var userNotifyOldTime:TimeInterval?
                let userNotifyDays:String
                var userNotifyOldDays:String?
                
                if userInfo["Old_Time"] != nil{
                    userNotifyOldTime = userInfo["Old_Time"] as? TimeInterval ?? nil
                }
                else{
                    userNotifyOldTime = nil
                }
                
                if userInfo["NotificationDays"] != nil{
                    userNotifyDays = userInfo["NotificationDays"] as! String
                }
                else{
                    userNotifyDays = ""
                }
                
                if userInfo["Old_NotificationDays"] != nil{
                    userNotifyOldDays = userInfo["Old_NotificationDays"] as? String ?? nil
                }
                else{
                    userNotifyOldDays = nil
                }
                
                if userNotifyOldTime != nil && userNotifyOldDays != nil {
                    self.notifyTime = Date(timeIntervalSince1970: userNotifyOldTime!)
                    self.notifyDay = userNotifyOldDays?.components(separatedBy: ",").map({ (x:String) -> Int in return Int(x)! })
                }
                else {
                    //if no temporary time (see NewTimeVC), then query the standard time
                    self.notifyTime = Date(timeIntervalSince1970: userNotifyTime)
                    self.notifyDay = userNotifyDays.components(separatedBy: ",").map({ (x:String) -> Int in return Int(x)! })
                }
                
                //Just check to make sure notifyDay is not empty array
                var checkDayIsSet = 0
                for day in self.notifyDay! {
                    if day == 1 {
                        checkDayIsSet = 1
                    }
                }
                if checkDayIsSet != 1 {
                    self.notifyDay! = [0,0,0,0,0,0,0]
                }
               
                //multiplier is needed because with old_time daysMissed will be off by one
                var multiplier = 0
                var daysMissed = 0
                var actualQuestSetMised = 0
                
                let currTime = Date()
                //TimeElapsed means difference between current and notification time.
                var timeElapsed = currTime.timeIntervalSince1970 - self.notifyTime!.timeIntervalSince1970
                print("Current time[\(currTime.timeIntervalSince1970)] - Notification Time[\(self.notifyTime!.timeIntervalSince1970)] = [\(timeElapsed)] --Possibaly old time dif if not any new time")
                
                if (timeElapsed >= 0) {
                    //increment the user count
                    multiplier+=1
                    daysMissed+=1
                    //actualQuestSetMised+=1
                    
                    //Recheck this logic. This is no correct with our 5 Days program.
                    
                    //Handle case if user changed time and then didn't check until after next notification
                    if (userNotifyOldTime != nil) {
                        print("we have old time. Means user changed the time.")
                        let newNotifyTime = Date(timeIntervalSince1970: userNotifyTime)
                        let oldTimeElapsed = newNotifyTime.timeIntervalSince1970 - self.notifyTime!.timeIntervalSince1970 // self.notifyTime will contain old values here.
                        print("New time - Old Time = [\(oldTimeElapsed)] ")
                        //if time has elapsed between old notify time and new notify time, that will count as one day missed
                        if (timeElapsed > oldTimeElapsed && oldTimeElapsed > 0){
                            daysMissed += 1
                            timeElapsed -= timeElapsed
                            print("time Elapsed changed \(timeElapsed)")
                        }
                        
                        //self.notifyTime! = newNotifyTime // we dont need to update time with new time. it will be recalcualted below. But we need to reset the new time with proper hour minutes time.
                        let hourPartOfNewNotifyTime = Double(Int(newNotifyTime.timeIntervalSince1970) % 86400)
                        let oldTimeWithoutHourPart = Double( Int(self.notifyTime!.timeIntervalSince1970) - (Int(self.notifyTime!.timeIntervalSince1970) % 86400))
                        self.notifyTime! = Date(timeIntervalSince1970: (oldTimeWithoutHourPart+hourPartOfNewNotifyTime))
                        
                            
                        self.notifyDay! = userNotifyDays.components(separatedBy: ",").map({ (x:String) -> Int in return Int(x)! })
                        
                        print("New notification after deducting old time \(newNotifyTime). set old time to null")
                        self.ref!.child("Old_Time").setValue(nil)
                        self.ref!.child("Old_NotificationDays").setValue(nil)
                        userNotifyOldTime = nil
                        userNotifyOldDays = nil
                    }
                    print("=wot\(timeElapsed)")
                    
                    
                    if timeElapsed > 0 {
                        daysMissed += Int(timeElapsed/Common.timeInterval)
                        multiplier += Int(timeElapsed/Common.timeInterval)
                        
                        //need to check how many question actually user lost.
                        
                        //weekday! is starting from Sunday to Saturday from 1 to 7 adjust according to our array.
                        var tempWeekDayHolder = Calendar(identifier: Calendar.Identifier.gregorian).dateComponents([.weekday], from: Date()).weekday! - 1
                        while(daysMissed > 0){
                            daysMissed-=1 // reduce
                            if self.notifyDay![tempWeekDayHolder] == 1 {
                                actualQuestSetMised+=1
                            }
                            tempWeekDayHolder-=1 //Reduce one day
                            if tempWeekDayHolder == -1 {
                                tempWeekDayHolder = 6 // Reset to Saturday if exceed
                            }
                        }
                    }
                    
                    
                    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                    let components = calendar.dateComponents([.weekday], from: self.notifyTime!)
                    print("CheckIfNeedUpdate. weekday \(components.weekday!)")
                    //components.weekday! is starting from Sunday to Saturday from 1 to 7 adjust according to our array.
                    var tempWeekDayHolder = components.weekday! - 1
                    
                    //Add multiplier and check if we can give notification on that day.
                    tempWeekDayHolder+=multiplier
                    tempWeekDayHolder%=7 // Reset to Sunday if exceed
                    
                    if (self.notifyDay![tempWeekDayHolder] == 0) {
                        while(self.notifyDay![tempWeekDayHolder] == 0){
                            multiplier+=1
                            tempWeekDayHolder+=1 //Add one day
                            tempWeekDayHolder%=7 // Reset to Sunday if exceed
                            print("In Loop \(tempWeekDayHolder)  \(multiplier)")
                        }
                    }
                    
                    print("=multipler\(multiplier)")
                    //set next question update to next day
                    self.notifyTime!.addTimeInterval(Common.timeInterval*Double(multiplier))
                    print("=new tiem \(self.notifyTime!) in seconds: \(self.notifyTime!.timeIntervalSince1970)")
                    if(userNotifyOldTime != nil){
                        self.ref!.child("Old_Time").setValue(self.notifyTime?.timeIntervalSince1970)
                    } else {
                        self.ref!.child("Time").setValue(self.notifyTime?.timeIntervalSince1970)
                    }
                }
                
                print("CheckIfNeedUpdate. \(Common.timeInterval)  \(Common.dayInSeconds)")
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                //update with next notification time
//                DispatchQueue.main.async {
//                    self.timeLabel.text! = dateFormatter.string(from: self.notifyTime!)
//                }
                
                self.invalidateTimer()
                self.setNextQuestionTimer()
//                print("countincreasedby\(actualQuestSetMised)")
                self.setQuestionCount(days: actualQuestSetMised)
                
//                let center = UNUserNotificationCenter.current()
//                center.getPendingNotificationRequests(completionHandler: {requests in
//                    for request in requests {
//                        print("Current pendingrequeestion \(request)")
//                    }
//
//                })
                
            }
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
            print("timer set for view update \(notifyTime!)")
            timer = Timer(fireAt: notifyTime!, interval: 0, target: self, selector: #selector(setTimer), userInfo: nil, repeats: false)
            RunLoop.main.add(timer!, forMode: .commonModes)
        }
    }
    
    //gets the next question by incrementing this user's count by the number of days elapsed since last check
    func setQuestionCount(days:Int) {
        self.ref!.child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            self.ref!.child(Common.USER_COUNT).setValue(value+(days * Common.dailyQuestionCount))
            self.getQuestion()
        })
    }

    //retrieves a question according to this user's count
    func getQuestion(){

        //get the count
        self.ref!.child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            //get the first question greater than or equal to count
            Database.database().reference().child(Common.QUESTION_PATH).queryOrdered(byChild: "count").queryStarting(atValue: value).queryLimited(toFirst: 3).observeSingleEvent(of: .value, with: {(snapshot) in
                //this is needed here because it gets tags twice for some reason
                //self.tagsList.removeAllTags()
                let result = snapshot.children.allObjects as! [DataSnapshot]
                if (result.count == 0) {
                    Server.showError(message: "Unable to load Questions.")
                } else {
                    
                    self.bQuestionsFromServerFetched = true;
                    
                    //have to append 3 questions at once
                    //var questionText = ""
                    var count = 0
                    
                    self.currentQuestionKey = [String]()
                    for question in result {
                        let qbody = question.value as? NSDictionary
                        if let qbody = qbody {
                            
                            self.QuestionsFromServer[count] =  (qbody["Text"] as? String ?? "Unable to load question")!
                            self.currentQuestionKey.append(qbody["Key"] as? String ?? "")
                            count+=1
                            
                            if let tags = qbody["Tags"] as? NSDictionary {
                                self.QuestionsFromServer[count] = ""
                                for (_, tag) in tags {
                                    self.QuestionsFromServer[count]  =  self.QuestionsFromServer[count] + (tag as? String ?? "")
                                }
                            }
                            count+=1
                            
                        } else {
                            self.QuestionsFromServer[count] = "Unable to load question"
                        }
                    }
                    self.showQuestionTable.layoutIfNeeded()
//                    self.showQuestionTable.estimatedRowHeight = 70;
//                    self.showQuestionTable.rowHeight = UITableViewAutomaticDimension;
                    self.showQuestionTable.reloadData();
                    print("Yes data reload.")
                }
            })
        }) { (err) in
            debugPrint(err)
        }
    }
 
    //saves a question with the given key
    func saveQuestion(keys:[String]){
        for key in keys {
            self.ref!.child("Saved").updateChildValues([key:true])
        }
    }
    
    //saves each question that was missed
    func saveMissedQuestions(days:Int){
        self.ref!.child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            print("question from \(value) to \(days) after")
            //get the first question greater than or equal to count
            Database.database().reference().child(Common.QUESTION_PATH).queryOrdered(byChild: "count").queryStarting(atValue: value+1).queryLimited(toFirst: UInt(days)*3).observeSingleEvent(of: .value, with: {(snapshot) in
                let result = snapshot.children.allObjects as! [DataSnapshot]
                if (result.count == 0) {
                    Server.showError(message: "Unable to load question.")
                }
                print(result)
                var keys = [String]()
                for qbody in result {
                    let qdata = qbody.value as? NSDictionary
                    if let qdata = qdata {
                        if let key = qdata["Key"] as? String {
                            keys.append(key)
                        }
                    }
                }
                self.saveQuestion(keys: keys)
            })
        }) { (err) in
            debugPrint(err)
        }
    }
    
    //shows the save actionSheet
    func showSaveOptions(){
        let ac = UIAlertController(title: "Question Options", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Save these questions", style: .default, handler: { (action) in
            self.saveQuestion(keys: self.currentQuestionKey)
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


class questionCell:UITableViewCell {
    @IBOutlet weak var questionHolder: UILabel!
}


