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
class ContactViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var subjectField: UITextField!
    
    @IBOutlet weak var messageBody: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBAction func sendEmail(_ sender: UIButton) {
        if (emailField.text! == ""){
            Server.showError(message: "Enter your email!")
        } else if (nameField.text! == "") {
            Server.showError(message: "Enter your name!")
        } else if (subjectField.text! == ""){
            Server.showError(message: "Enter your subject!")
        } else if (messageBody.text! == "") {
            Server.showError(message: "Enter a message body!")
        } else {
            submit()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTap()
        //styling to make the textview look like a textfield lol
        messageBody.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        messageBody.layer.borderWidth = 1.0
        
        if let user = Auth.auth().currentUser {
            Database.database().reference().child(Common.USER_PATH).child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                let userInfo = snapshot.value as? NSDictionary
                if let userInfo = userInfo {
                    self.nameField.text! = userInfo["Name"] as? String ?? ""
                    self.emailField.text! = userInfo["Email"] as? String ?? ""
                    
                }
            })
        }
    }
    
    func toggleButtons(toggle:Bool){
        DispatchQueue.main.async {
            self.emailField.isEnabled = toggle
            self.nameField.isEnabled = toggle
            self.subjectField.isEnabled = toggle
            self.messageBody.isEditable = toggle
            self.submitButton.isEnabled = toggle
            if (!toggle) {
                self.submitButton.setTitle("Submitting...", for: .disabled)
            } else {
                self.submitButton.setTitle("Submit", for: .normal)
            }
        }
    }
    
    func submit(){
        //get user information to include in email body
        toggleButtons(toggle: false)
        let user = nameField.text!
        let email = emailField.text!
        
        var body = "<p>\(user),\(email) submitted feedback:</p>"
        body+="<p>\(messageBody.text!)</p>"
        
        let subject = "Feedback from \(email): \(subjectField.text!)"
        
        let params = ["subject":subject, "content":body] as [String:Any]
        
        Server.post(urlRoute: Server.hostURL + "email/", params: params, callback: self.submitQuestionCallback(data:), errorMessage: "Could not submit question!")
        Common.showSuccess(message: "Submitted feedback!")
        DispatchQueue.main.async {
            self.messageBody.text! = ""
            self.subjectField.text! = ""
        }
        toggleButtons(toggle: true)
    }
    
    func submitQuestionCallback(data:Data){
       //blank method
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x:0, y:250), animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
    }
}
