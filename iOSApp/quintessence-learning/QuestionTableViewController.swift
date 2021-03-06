//
//  QuestionViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/20/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
struct Question {
    var text:String
    var tags:[String]
    var key:String
}

class QuestionTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var questions = [Question]()
    var filteredQuestions = [Question]()
    var ascending = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Questions"
        
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        DispatchQueue.global(qos: .background).async {
            self.getQuestions()
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(getQuestions), for: UIControlEvents.valueChanged)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(showLogout))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "More...", style: .plain, target: self, action: #selector(showActions))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //number of cells to render
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if searchController.isActive && searchController.searchBar.text != "" {
            return filteredQuestions.count
        }
        return questions.count
    }
    
    //renders the cell with the title as the question
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let question = (searchController.isActive && searchController.searchBar.text != "") ? filteredQuestions[indexPath.row] : questions[indexPath.row]
        cell.textLabel?.text = question.text
        return cell
    }
    
    //displays a message if no questions loaded
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (questions.count > 0){
            self.tableView.backgroundView = nil;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
            return 1
        } else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
            messageLabel.text = "Please pull down to refresh"
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = NSTextAlignment.center
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            return 0
        }
    }
    
    //handle tap on cell to display modal for respective question
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let modalViewController = storyboard?.instantiateViewController(withIdentifier: "question") as! ModalViewController
        let question = (searchController.isActive && searchController.searchBar.text != "") ? filteredQuestions[indexPath.row] : questions[indexPath.row]
        modalViewController.data = question
        modalViewController.row = indexPath
        modalViewController.modalDelegate = self
        modalViewController.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(modalViewController, animated: true, completion: nil)
    }
    
    @IBAction func addQuestion(_ sender: UIBarButtonItem) {
        let createViewController = storyboard?.instantiateViewController(withIdentifier: "Create") as! CreateViewController
        createViewController.modalDelegate = self
        createViewController.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(createViewController, animated: true, completion: nil)
    }
    //filters based on text
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredQuestions = questions.filter { question in
            return question.text.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    func qCallback(data: Data) throws {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        if let dict = json as? [String:[[String:Any]]] {
            var responseData = [Question]()
            let questionResponse : [[String:Any]] = dict["questions"]!
            for question in questionResponse {
                responseData.append(Question(text: question["text"]! as! String, tags: question["taglist"]! as! [String], key: question["key"]! as! String))
            }
            self.questions = responseData
        }
    }
    func getQuestions(){
        let urlRoute = Server.hostURL + "/profile/read"
        let params = ["ascending": ascending]
        
        Server.post(urlRoute: urlRoute, params: params, callback: qCallback, errorMessage: "An error occurred in retrieving questions!")
        
        DispatchQueue.main.async { [unowned self] in
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func showLogout(){
        let ac = UIAlertController(title: "Confirm", message: "Are you sure you want to log out?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Logout", style: .default, handler: logout(action: )))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func logout(action:UIAlertAction){
        do {
            try Auth.auth().signOut()
            let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! UINavigationController
            self.navigationController!.present(welcomeScreen, animated: true)
        } catch {
            Server.showError(message: error.localizedDescription)
        }
    }
    
    func showActions(){
        let ac = UIAlertController(title: "Search by...", message: nil, preferredStyle: .actionSheet)
        
        let sendButton = UIAlertAction(title: "Oldest to Newest", style: .default, handler: { (action) -> Void in
            self.ascending = true
            self.getQuestions()
        })
        
        let  deleteButton = UIAlertAction(title: "Newest to Oldest", style: .default, handler: { (action) -> Void in
            self.ascending = false
            self.getQuestions()
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        
        ac.addAction(sendButton)
        ac.addAction(deleteButton)
        ac.addAction(cancelButton)
        
        self.navigationController!.present(ac, animated: true, completion: nil)
    }
}

extension QuestionTableViewController : ModalDelegate {
    func refreshQuestions() {
        self.getQuestions()
    }
    
    func modalClose(row: IndexPath) {
        tableView.deselectRow(at: row, animated: true)
    }
}

extension QuestionTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}


