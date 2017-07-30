//
//  FeedbackViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/24/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit

class FeedbackViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //modally present user to submit their own question
        if indexPath.row == 0 {
            let submitView = self.storyboard?.instantiateViewController(withIdentifier: "Submit") as! SubmitViewController
            submitView.row = indexPath
            submitView.updateDelegate = self
            submitView.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(submitView, animated: true, completion: nil)
        }
    }
}

extension FeedbackViewController : UpdateQuestionDelegate {
    func refreshQuestions() {
        return
    }
    
    func modalClose(row: IndexPath) {
        tableView.deselectRow(at: row, animated: true)
    }
}
