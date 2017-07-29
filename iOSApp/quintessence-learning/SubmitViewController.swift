//
//  CreateViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/24/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import TagListView

class SubmitViewController: ModalViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tagFieldCreate: UITextField!
    @IBOutlet weak var tagListCreate: TagListView!
    
    
    @IBAction override func onAddTag(_ sender: Any) {
        if (tagFieldCreate.text!.characters.count > 0) {
            tagListCreate.addTag(tagFieldCreate.text!)
            tagFieldCreate.text! = ""
        } else {
            Server.showError(message: "Input a tag!")
        }
    }
    
    @IBAction func onAddQuestion(_ sender: Any) {
        if (textField!.text! == ""){
            Server.showError(message: "Input a question!")
        }
        else if (tagListCreate.tagViews.count == 0){
            Server.showError(message: "Input tags!")
        } else {
            createQuestion()
        }
    }
    
    @IBAction override func onCancel(_ sender: UIButton) {
        super.onClose(sender)
    }
    
    override func viewDidLoad() {
        tagListCreate.delegate = self
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.tintColor = UIColor.black
        view.isOpaque = false
    }
    
    func createQuestion(){
        var tags = [String]()
        for tag:TagView in tagListCreate.tagViews {
            tags.append(tag.titleLabel!.text!)
        }
        //TODO send email
    }
    
}
