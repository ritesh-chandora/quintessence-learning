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
    
    @IBOutlet weak var questionLabel: UITextView!
    @IBOutlet weak var tagsList: TagListView!
    @IBOutlet weak var savedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    //checks to see if new question has to be loaded and then loads a timer in case user stays on that screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
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
        
        user = Auth.auth().currentUser!
        ref = Database.database().reference().child(Common.USER_PATH).child(user!.uid)
        
        getQuestion()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(showSaveOptions))
    }
    
    //checks to see if update is needed
    func checkIfNeedUpdate(){
        print("Checkin to see if update needed")
        
        //query both old time (if any) and the current notification time
        ref!.child("Old_Time").observeSingleEvent(of: .value, with: { (data) in
            self.ref!.child("Time").observeSingleEvent(of: .value, with: { (time) in
                let oldTime = data.value as? TimeInterval ?? nil
                
                //if old time exists, that is the next notification time
                if oldTime != nil {
                    self.notifyTime = Date(timeIntervalSince1970: oldTime!)
                } else {
                    //if no temporary time (see NewTimeVC), then query the standard time
                   self.notifyTime = Date(timeIntervalSince1970: time.value as! TimeInterval)
                }
                
                let currTime = Date()
                let timeElapsed = currTime.timeIntervalSinceReferenceDate - self.notifyTime!.timeIntervalSinceReferenceDate
                
                print(timeElapsed)
                //if the time has passed since notification date
                if (timeElapsed > 0) {
                    var daysMissed = 0
                    
                    //Handle case if user changed time and then didn't check until after next notification
                    if (oldTime != nil) {
                        let newNotifyTime = Date(timeIntervalSince1970: time.value as! TimeInterval)
                        
                        //if time has elapsed between old notify time and new notify time, that will count as one day missed
                        if (timeElapsed > (newNotifyTime.timeIntervalSinceReferenceDate) - self.notifyTime!.timeIntervalSinceReferenceDate){
                            daysMissed += 1
                        }
                        self.ref!.child("Old_Time").setValue(nil)
                    }
                    //check for missed days and if so, add those questions to saved questions
                    daysMissed += Int(timeElapsed/Common.dayInSeconds)
                    if (daysMissed > 0){
                        print("missed \(daysMissed) of questions!")
                        self.saveMissedQuestions(days: daysMissed)
                    }
                    
                    //increment the user count
                    self.setQuestionCount(days: daysMissed + 1)
                    
                    //set next question update to next day
                    self.notifyTime!.addTimeInterval(Common.dayInSeconds)
                    self.ref!.child("Time").setValue(self.notifyTime?.timeIntervalSince1970)
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                //update with next notification time
                DispatchQueue.main.async {
                    self.timeLabel.text! = dateFormatter.string(from: self.notifyTime!)
                }
                
                self.setNextQuestionTimer()
                self.getQuestion()
            })
        })
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
        self.ref!.child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            self.ref!.child(Common.USER_COUNT).setValue(value+days)
        })
    }

    //retrieves a question according to this user's count
    func getQuestion(){
        print("getting question")
        self.questionLabel.text = "Loading Question..."
        //get the count

        self.ref!.child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            //get the first question greater than or equal to count
            Database.database().reference().child(Common.QUESTION_PATH).queryOrdered(byChild: "count").queryStarting(atValue: value).queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: {(snapshot) in
                
                //this is needed here because it gets tags twice for some reason
                self.tagsList.removeAllTags()
                let result = snapshot.children.allObjects as! [DataSnapshot]
                print(result)
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
        self.ref!.child("Saved").queryOrderedByKey().queryEqual(toValue: key).observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.exists()
            print(snapshot.exists())
            if(data){
                Server.showError(message: "Already saved this question!")
            } else {
                self.ref!.child("Saved").updateChildValues([self.currentQuestionKey:true])
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
        self.ref!.child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            //get the first question greater than or equal to count
            Database.database().reference().child(Common.QUESTION_PATH).queryOrdered(byChild: "count").queryStarting(atValue: value).queryLimited(toFirst: UInt(days)).observeSingleEvent(of: .value, with: {(snapshot) in
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
