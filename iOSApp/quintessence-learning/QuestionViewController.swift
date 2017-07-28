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
class QuestionViewController: UIViewController {

    var notifyTime:Date?
    var timer:Timer?
    var user:User?
    var ref:DatabaseReference?
    var currentQuestionKey = ""

    let defaults = UserDefaults.standard
    
    @IBOutlet weak var questionLabel: UITextView!
    @IBOutlet weak var savedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = Auth.auth().currentUser!
        ref = Database.database().reference()
        
        let notifyTime = defaults.object(forKey: "NotifyTime") as! Date
        print(notifyTime)
        
        getQuestion()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(showSaveOptions))
    }
    
//    func isTimeToGetNext()
    
    //gets the next question by incrementing this user's count
    func getNextQuestion() {
        print("getting next question")
        self.ref!.child(Common.USER_PATH).child(user!.uid).child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            self.ref!.child(Common.USER_PATH).child(self.user!.uid).child(Common.USER_COUNT).setValue(value+1)
            self.getQuestion()
        })
    }

    //retrieves a question according to this user's count
    func getQuestion(){
        print("getting question")
        //get the count
        self.ref!.child(Common.USER_PATH).child(user!.uid).child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! Int
            //get the first question greater than or equal to count
            self.ref!.child(Common.QUESTION_PATH).queryOrdered(byChild: "count").queryStarting(atValue: value).queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: {(snapshot) in
                let result = snapshot.children.allObjects as! [DataSnapshot]
                if (result.count == 0) {
                    self.questionLabel.text = "Unable to load question"
                }
                let qbody = result[0].value as? NSDictionary
                if let qbody = qbody {
                    self.questionLabel.text = qbody["Text"] as? String ?? "Unable to load question"
                    self.currentQuestionKey = qbody["Key"] as? String ?? ""
                    
                } else {
                    self.questionLabel.text = "Unable to load question"
                }
            })
        }) { (err) in
            print(err)
        }
    }
 
    //shows the save actionSheet
    func showSaveOptions(){
        let ac = UIAlertController(title: "Question Options", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Save this question", style: .default, handler: { (action:UIAlertAction) in
            self.ref!.child(Common.USER_PATH).child(self.user!.uid).child("Saved").queryOrderedByKey().queryEqual(toValue: self.currentQuestionKey).observeSingleEvent(of: .value, with: { (snapshot) in
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
        }))
        ac.addAction(UIAlertAction(title: "View all saved questions", style: .default, handler: { (action:UIAlertAction ) in
            let savedView = self.storyboard?.instantiateViewController(withIdentifier: "SavedQ") as! SavedTableViewController
            self.navigationController?.pushViewController(savedView, animated: true)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(ac, animated: true)
    }
}
