//
//  ContactViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/29/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class ContactViewController: UIViewController {

    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var subjectField: UITextField!
    
    @IBOutlet weak var messageBody: UITextView!
    
    @IBAction func sendEmail(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //styling to make the textview look like a textfield lol
        messageBody.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        messageBody.layer.borderWidth = 1.0
        
        
        Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let userInfo = snapshot.value as? NSDictionary
            if let userInfo = userInfo {
                self.nameField.text! = userInfo["Name"] as! String
                self.emailField.text! = userInfo["Email"] as! String
                
            } else {
                Server.showError(message: "Unable to retrieve user info!")
            }
        })
    }
    

}
