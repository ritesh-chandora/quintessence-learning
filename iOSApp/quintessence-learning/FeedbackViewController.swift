//
//  FeedbackViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/24/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class FeedbackViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //modally present user to submit their own question
        if indexPath.row == 0 {
            let submitView = self.storyboard?.instantiateViewController(withIdentifier: "Submit") as! SubmitViewController
            submitView.row = indexPath
            submitView.modalDelegate = self
            submitView.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(submitView, animated: true, completion: nil)
        } else if indexPath.row == 2 {
            //ebook
            Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).child("Type").observeSingleEvent(of: .value, with: { (snapshot) in
                let type = snapshot.value as! String
                if (type == "premium"){
                    let ebook = self.storyboard?.instantiateViewController(withIdentifier: "ebook")
                    self.navigationController?.pushViewController(ebook!, animated: true)
                } else {
                    let premiumScreen = self.storyboard?.instantiateViewController(withIdentifier: "Premium") as! PremiumPurchaseViewController
                    self.present(premiumScreen, animated: true)
                }
            })
        }
    }
}

extension FeedbackViewController : ModalDelegate {
    func refreshQuestions() {
        return
    }
    
    func modalClose(row: IndexPath) {
        tableView.deselectRow(at: row, animated: true)
    }
}
