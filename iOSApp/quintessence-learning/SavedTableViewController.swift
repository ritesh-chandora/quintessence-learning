//
//  SavedTableViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/24/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class SavedTableViewController: UITableViewController {

    var ref:DatabaseReference?
    var user:User?
    var questions = [Question]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Saved Questions"
        ref = Database.database().reference()
        user = Auth.auth().currentUser!
        
        //observe and update table view whenever the saved questions is changed
        ref!.child(Common.USER_PATH).child(user!.uid).child("Saved").observe(.value, with: { snapshot in
            var newQuestions = [Question]()
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                self.ref!.child(Common.QUESTION_PATH).queryOrderedByKey().queryEqual(toValue: item.key).observeSingleEvent(of: .value, with: { (snapshot) in
                    let result = snapshot.children.allObjects as! [DataSnapshot]
                    for ques in result {
                        let qbody = ques.value as! NSDictionary
                        let qtext = qbody["Text"] as! String
                        
                        var qtags = [String]()
                        let tags = qbody["Tags"] as! [String:String]
                        for key in tags.keys {
                            qtags.append(tags[key]!)
                        }
                        
                        let qkey = qbody["Key"] as! String
                    
                        newQuestions.append(Question(text: qtext, tags: qtags, key: qkey))
                    }
                    self.questions = newQuestions
                    print(self.questions)
                    self.tableView.reloadData()
                })
            }
            
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    //question display
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedCell", for: indexPath)
        let question = questions[indexPath.row]
        
        cell.textLabel?.text = question.text
        cell.detailTextLabel?.text = question.tags.joined(separator: ",")
        print(question.tags.joined(separator: ","))
        
        return cell
    }
    
    //remove saved questions
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let question = questions[indexPath.row]
            ref!.child(Common.USER_PATH).child(user!.uid).child("Saved").child(question.key).removeValue()
        }
    }
}
