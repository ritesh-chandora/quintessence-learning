//
//  TagTableViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/31/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit

protocol TagDelegate {
    func displayWith(tag:String) -> Void
}

class TagTableViewController: UITableViewController {

    var tagDelegate:TagDelegate?
    var tags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = tags[indexPath.row]
        tagDelegate?.displayWith(tag: tag)
        self.navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tags[indexPath.row]
        return cell
    }


}
