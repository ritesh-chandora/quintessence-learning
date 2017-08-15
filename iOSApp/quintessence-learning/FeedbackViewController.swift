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
            let ebookUrl = URL(string: "url")
            if let ebookUrl = ebookUrl {
                let ebookView = self.storyboard?.instantiateViewController(withIdentifier: "ebook")
                
                let webView = UIWebView(frame: ebookView!.view.frame)
                let urlRequest = URLRequest(url: ebookUrl)
                webView.loadRequest(urlRequest)
                
                ebookView!.view.addSubview(webView)
                
                self.navigationController?.pushViewController(ebookView!, animated: true)
            }
        } else if indexPath.row == 3 {
            //FAQ
            let FAQ = FAQViewController()
            self.navigationController?.pushViewController(FAQ, animated: true)
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
