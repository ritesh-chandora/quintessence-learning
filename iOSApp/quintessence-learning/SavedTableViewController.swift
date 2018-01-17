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

    let searchController = UISearchController(searchResultsController: nil)
    var ref:DatabaseReference?
    var user:User?
    var questions = [Question]()
    var tags = [String]()
    var filteredQuestions = [Question]()
    var tagFilteringActive = false
    var emptyMessage = "No questions currently saved!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        user = Auth.auth().currentUser!
        
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
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
                    self.getAllTags()
                    self.tableView.reloadData()
                })
            }
        })
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchOptions))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searchController.isActive && searchController.searchBar.text != "") || tagFilteringActive ? filteredQuestions.count : questions.count
    }
    
    //displays a message if no questions loaded
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (questions.count > 0){
            self.tableView.backgroundView = nil;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            return 1
        } else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
            messageLabel.text = self.emptyMessage
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = NSTextAlignment.center
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            return 0
        }
    }
    
    //displays a modal of the question
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let question = (searchController.isActive && searchController.searchBar.text != "") || tagFilteringActive ? filteredQuestions[indexPath.row] : questions[indexPath.row]
        let savedQuestionView = self.storyboard?.instantiateViewController(withIdentifier: "Saved") as! SavedQuestionViewController
        savedQuestionView.modalDelegate = self
        savedQuestionView.data = question
        savedQuestionView.row = indexPath
        savedQuestionView.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(savedQuestionView, animated: true)
        print("showing the question.")
    }
    
    //question display in cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedCell", for: indexPath)
        let question = (searchController.isActive && searchController.searchBar.text != "") || tagFilteringActive ? filteredQuestions[indexPath.row] : questions[indexPath.row]
        
        cell.textLabel?.text = question.text
        cell.detailTextLabel?.text = question.tags.joined(separator: ",")
        
        return cell
    }
    
    func showSearchOptions(){
        let options = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        options.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        if (tagFilteringActive){
            options.addAction(UIAlertAction(title: "Clear search", style: .default, handler: { (action) in
                self.filteredQuestions = [Question]()
                self.tagFilteringActive = false
                self.tableView.reloadData()
            }))
        }
        
        options.addAction(UIAlertAction(title: "Search by Tags", style: .default, handler: { (action) in
            let tagViewController = self.storyboard?.instantiateViewController(withIdentifier: "TagTable") as! TagTableViewController
            tagViewController.tagDelegate = self
            tagViewController.tags = self.tags
            self.navigationController?.pushViewController(tagViewController, animated: true)
        }))
        present(options, animated: true)
    }
    
    //filters based on text
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredQuestions = questions.filter { question in
            return question.text.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    func getAllTags(){
        var allTags = Set<String>()
        for question in questions {
            for tag in question.tags {
                if (!allTags.contains(tag)){
                    allTags.insert(tag)
                }
            }
        }
        self.tags = Array(allTags)
    }
}

extension SavedTableViewController : ModalDelegate {
    func refreshQuestions() {
        return
    }
    
    func modalClose(row: IndexPath) {
        tableView.deselectRow(at: row, animated: true)
    }
}

extension SavedTableViewController : TagDelegate {
    func displayWith(tag: String) {
        tagFilteringActive = true
        self.filteredQuestions = questions.filter { question in
            return question.tags.contains(tag)
        }
        self.tableView.reloadData()
    }
}

extension SavedTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
