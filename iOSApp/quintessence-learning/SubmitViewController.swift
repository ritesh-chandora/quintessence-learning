//
//  CreateViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/24/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import TagListView
import FirebaseAuth
import FirebaseDatabase

class SubmitViewController: ModalViewController {
    
    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var listTagField: UITextField!
    @IBOutlet weak var listTags: TagListView!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var closeCreatButton: UIButton!
    @IBOutlet weak var tagAddButton: UIButton!
    
    @IBAction override func onAddTag(_ sender: Any) {
        if (listTagField.text!.characters.count > 0) {
            listTags.addTag(listTagField.text!)
            listTagField.text! = ""
        } else {
            Server.showError(message: "Input a tag!")
        }
    }
    
    @IBAction func onAddQuestion(_ sender: Any) {
        if (textField!.text! == ""){
            Server.showError(message: "Input a question!")
        }
        else if (listTags.tagViews.count == 0){
            Server.showError(message: "Input tags!")
        } else {
            toggleButtons(toggle: false)
            submitQuestion()
        }
    }
    
    @IBAction override func onCancel(_ sender: UIButton) {
        super.onClose(sender)
    }
    
    override func viewDidLoad() {
        self.hideKeyboardOnTap()
        listTags.delegate = self
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isOpaque = false
    }
    
    func toggleButtons(toggle:Bool){
        DispatchQueue.main.async {
            self.textField.isEnabled = toggle
            self.listTagField.isEnabled = toggle
            self.submitButton.isEnabled = toggle
            self.closeCreatButton.isEnabled = toggle
            if (toggle == false){
                self.submitButton.setTitle("Submitting...", for: .normal)
            } else {
                self.submitButton.setTitle("Submit", for: .normal)
            }
        }
    }
    
    //submit question by formatting email body and sending via post request
    func submitQuestion(){
        
        var tags = [String]()
        for tag:TagView in listTags.tagViews {
            tags.append(tag.titleLabel!.text!)
        }
        
        let tagString = tags.joined(separator: ",")
        
        //get user information to include in email body
        Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let userInfo = snapshot.value as? NSDictionary
            if let userInfo = userInfo {
                let user = userInfo["Name"] as! String
                let email = userInfo["Email"] as! String
                
                var content = "<p>\(user),\(email) submitted a question:</p>"
                content+="<p>Question:\(self.textField.text!)</p>"
                content+="<p>Tags:\(tagString)</p>"
                
                let subject = "New question from \(email)"
                
                let params = ["subject":subject, "content":content] as [String:Any]
                
                Server.post(urlRoute: Server.hostURL + "/email", params: params, callback: self.submitQuestionCallback(data:), errorMessage: "Could not submit question!")
                
            } else {
                Server.showError(message: "Unable to retrieve user info!")
                self.toggleButtons(toggle: true)
            }
        })
    }
    
    func submitQuestionCallback(data:Data){
        Common.showSuccess(message: "Submitted question!")
        DispatchQueue.main.async {
            self.textField.text! = ""
            self.listTagField.text! = ""
            self.listTags.removeAllTags()
        }
        toggleButtons(toggle: true)
    }
}
