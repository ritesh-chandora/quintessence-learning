//
//  QuestionViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/20/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit

struct Question {
    var text:String
    var tags:[String]
    var key:String
}

class QuestionViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    let hostURL = "http://localhost:3001"
    
    var questions = [Question]()
    var ascending = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        DispatchQueue.global(qos: .background).async {
            self.getQuestions()
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(getQuestions), for: UIControlEvents.valueChanged)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //number of cells to render
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    //renders the cell with the title as the question
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let question = questions[indexPath.row]
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
    
    //handles tapping of question to segue to modal
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let modalViewController = segue.destination as! ModalViewController
        if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)!
            modalViewController.data = questions[indexPath.row]
            modalViewController.updateDelegate = self
            self.tableView.deselectRow(at: indexPath, animated: true)
        } else {
            DispatchQueue.main.async { [unowned self] in
                self.showError()
            }
        }
    }
    
    //displays an error
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem retrieving questions; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func getQuestions(){
        let params = ["ascending": ascending]
        guard let reqBody = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        
        let urlRoute = self.hostURL + "/profile/read"
        //set up POST request
        guard let url = URL(string: urlRoute) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = reqBody
        
        //excute POST request
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let dict = json as? [String:[[String:Any]]] {
                        var responseData = [Question]()
                        let questionResponse : [[String:Any]] = dict["questions"]!
                        for question in questionResponse { 
                            responseData.append(Question(text: question["text"]! as! String, tags: question["taglist"]! as! [String], key: question["key"]! as! String))
                        }
                        self.questions = responseData
                    }
                }catch {
                    DispatchQueue.main.async {
                        self.showError()
                    }
                }
            }
        }.resume()
        DispatchQueue.main.async { [unowned self] in
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
}

extension QuestionViewController : UpdateQuestionDelegate {
    func refreshQuestions() {
         self.getQuestions()
    }
}


