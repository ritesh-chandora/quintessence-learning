//
//  CreateViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/24/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import TagListView

class CreateViewController: ModalViewController {
    
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
        let params = ["question": textField!.text!, "tags": tags] as [String : Any]
        let urlRoute = Server.hostURL + "/profile/create"
        
        Server.post(urlRoute: urlRoute, params: params, callback: createCallBack(data:), errorMessage: "Unable to create question!")
    }
    
    func createCallBack(data: Data) throws {
        //if there is a response body, then it failed to edit, exit edit mode
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        if let dict = json as? [String:String]{
            if (dict["message"] != "success"){
                Server.showError(message: dict["message"]!)
            } else {
                //otherwise update the table and close the modal
                updateDelegate.refreshQuestions()
                self.closeModal()
            }
        }
    }
}
