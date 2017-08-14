//
//  PastQuestionsTableViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 8/5/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class PastQuestionsTableViewController: SavedTableViewController {
    
    override func viewDidLoad() {
        
        //--------from super class
        ref = Database.database().reference()
        user = Auth.auth().currentUser!
        
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        //---------end from superclass
        
        emptyMessage = "No past questions!"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchOptions))
        
        ref!.child(Common.USER_PATH).child(user!.uid).child(Common.USER_COUNT).observeSingleEvent(of: .value, with: { snapshot in
            let count = snapshot.value as? Int ?? nil
            if (count == nil) {
                Server.showError(message: "Could not load current question count!")
            } else if (count != 0){
                var allQuestions = [Question]()
                //get all questions up to the user's count
                self.ref!.child(Common.QUESTION_PATH).queryOrderedByKey().queryLimited(toFirst: UInt(count!)).observeSingleEvent(of: .value, with: { (questions) in
                    let questionsResponse = questions.children.allObjects as! [DataSnapshot]
                    for questionData in questionsResponse {
                        let questionData = questionData.value as! NSDictionary
                        
                        //get the tags in a string array
                        var qtags = [String]()
                        let tags = questionData["Tags"] as! [String:String]
                        for key in tags.keys {
                            qtags.append(tags[key]!)
                        }
                        let question = Question(text: questionData["Text"] as! String, tags: qtags, key: questionData["Key"] as! String)
                        allQuestions.append(question)
                    }
                    self.questions = allQuestions
                    self.getAllTags()
                    self.tableView.reloadData()
                })
            }
        })
    }
}
