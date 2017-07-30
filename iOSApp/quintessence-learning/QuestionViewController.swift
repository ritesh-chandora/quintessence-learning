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
class QuestionViewController: UIViewController {

    var notifyTime:Date?
    var timer:Timer?
    var user:User?
    var ref:DatabaseReference?
    var currentQuestionKey = ""
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var questionLabel: UITextView!
    @IBOutlet weak var tagsList: TagListView!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if(defaults.object(forKey: "NotifyTime") == nil){
            Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).child("Time").observeSingleEvent(of: .value, with: { (snapshot) in
                self.notifyTime = Date(timeIntervalSince1970: snapshot.value as! TimeInterval)
                self.defaults.set(self.notifyTime, forKey: "NotifyTime")
                self.checkIfNeedUpdate()
            })
        } else {
            checkIfNeedUpdate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = Auth.auth().currentUser!
        ref = Database.database().reference()
        getQuestion()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(showSaveOptions))
    }
    
    //checks to see if update is needed
    func checkIfNeedUpdate(){
        print("Checkin to see if update needed")
        
        //if tempTime exists, means there is a leftover question to retrieve
        if (defaults.object(forKey: "TempTime") as? Date != nil) {
            notifyTime = defaults.object(forKey: "TempTime") as! Date
        } else {
            notifyTime = defaults.object(forKey: "NotifyTime") as? Date
        }
        let currTime = Date()
        let timeElapsed = currTime.timeIntervalSinceReferenceDate - notifyTime!.timeIntervalSinceReferenceDate
       
        print(timeElapsed)
        //if the time has passed since notification date
        if (timeElapsed > 0) {
            var daysMissed = 0
            if (defaults.object(forKey: "TempTime") != nil) {
                let newNotifyTime = defaults.object(forKey: "NotifyTime") as? Date
                //if time has elapsed between old notify time and new notify time, that will count as one day missed 
                if (timeElapsed > (newNotifyTime!.timeIntervalSinceReferenceDate) - notifyTime!.timeIntervalSinceReferenceDate){
                    daysMissed += 1
                }
                defaults.set(nil, forKey: "TempTime")
            }
            //check for missed days and if so, add those questions to saved questions
            daysMissed += Int(timeElapsed/Common.dayInSeconds)
            if (daysMissed > 0){
                print("missed \(daysMissed) of questions!")
                saveMissedQuestions(days: daysMissed)
            }
            
            //increment the user count
            setQuestionCount(days: daysMissed + 1)
            
            //set next question update to next day
            notifyTime!.addTimeInterval(Common.dayInSeconds)
            defaults.set(notifyTime, forKey: "NotifyTime")
            Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).child("Time").setValue(notifyTime?.timeIntervalSince1970)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        //update with next notification time
        DispatchQueue.main.async {
            self.timeLabel.text! = dateFormatter.string(from: self.notifyTime!)
        }
        setNextQuestionTimer()
        getQuestion()
    }
    
    //sets a timer to retrieve next question if user leaves this view controller running
    func setNextQuestionTimer(){
        //invalid previous timer, if any
        if let timer = timer {
            timer.invalidate()
        }
        timer = Timer(fireAt: notifyTime!, interval: Common.dayInSeconds, target: self, selector: #selector(checkIfNeedUpdate), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
        
    }
    
    //gets the next question by incrementing this user's count by the number of days elapsed since last check
    func setQuestionCount(days:Int) {
        print("getting next question after \(days) days")
        self.ref!.child(Common.USER_PATH).child(user!.uid).child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            self.ref!.child(Common.USER_PATH).child(self.user!.uid).child(Common.USER_COUNT).setValue(value+days)
        })
    }

    //retrieves a question according to this user's count
    func getQuestion(){
        print("getting question")
        self.questionLabel.text = "Loading Question..."
        //get the count

        self.ref!.child(Common.USER_PATH).child(user!.uid).child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            //get the first question greater than or equal to count
            self.ref!.child(Common.QUESTION_PATH).queryOrdered(byChild: "count").queryStarting(atValue: value).queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: {(snapshot) in
                
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
                            print(tags)
                            for (_, tag) in tags {
                                print(tag)
                                self.tagsList.addTag(tag as? String ?? "")
                            }
                        }
                    } else {
                        self.questionLabel.text = "Unable to load question"
                    }
                }
            })
        }) { (err) in
            print(err)
        }
    }
 
    //saves a question with the given key
    func saveQuestion(key:String, showError:Bool){
        self.ref!.child(Common.USER_PATH).child(self.user!.uid).child("Saved").queryOrderedByKey().queryEqual(toValue: key).observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.exists()
            print(snapshot.exists())
            if(data){
                Server.showError(message: "Already saved this question!")
            } else {
                self.ref!.child(Common.USER_PATH).child(self.user!.uid).child("Saved").updateChildValues([self.currentQuestionKey:true])
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
        })
    }
    
    //saves each question that was missed
    func saveMissedQuestions(days:Int){
        self.ref!.child(Common.USER_PATH).child(user!.uid).child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            //get the first question greater than or equal to count
            self.ref!.child(Common.QUESTION_PATH).queryOrdered(byChild: "count").queryStarting(atValue: value).queryLimited(toFirst: UInt(days)).observeSingleEvent(of: .value, with: {(snapshot) in
                let result = snapshot.children.allObjects as! [DataSnapshot]
                if (result.count == 0) {
                    self.questionLabel.text = "Unable to load question"
                }
                print("Missed \(result.count) questions!")
                //loop through result and save each question
            })
        }) { (err) in
            print(err)
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
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(ac, animated: true)
    }
}
