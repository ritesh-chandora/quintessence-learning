//
//  DetailViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/21/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import TagListView

protocol ModalDelegate {
    func refreshQuestions()
    func modalClose(row: IndexPath)
}

class ModalViewController: UIViewController, TagListViewDelegate {
    
    @IBOutlet weak var text: UITextField!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var addTagLabel: UILabel!
    
    @IBOutlet weak var tagList: TagListView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addTagButton: UIButton!
    
    //handles adding tag
    @IBAction func onAddTag(_ sender: Any) {
        if (tagField.text!.characters.count > 0) {
            tagList.addTag(tagField.text!)
            tagField.text! = ""
        } else {
            Server.showError(message: "Input a tag!")
        }
        
    }
    
    //activates edit mode
    @IBAction func onEdit(_ sender: UIButton) {
        configButtons(editMode: true)
    }
    
    //confirms edits, will push to server and reload table data
    @IBAction func onConfirm(_ sender: UIButton) {
        configButtons(editMode: false)
        updateQuestion()
    }
    
    //cancels the edit, restores to original data
    @IBAction func onCancel(_ sender: UIButton) {
        loadData()
        configButtons(editMode: false)
        
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        closeModal()
    }
    
    var data : Question!
    var row : IndexPath!
    var modalDelegate: ModalDelegate!
    
    override func viewDidLoad() {
        loadData()
        tagList.delegate = self
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isOpaque = false
    }

    //loads default data
    func loadData(){
        DispatchQueue.main.async { [unowned self] in
            self.text.text! = self.data!.text
            self.tagList.removeAllTags()
            self.tagList.addTags(self.data!.tags)
        }
    }
    
    //configures the buttons to enter edit mode or exit
    func configButtons(editMode:Bool){
        closeButton.isEnabled = !editMode
        closeButton.isHidden = editMode
        editButton.isHidden = editMode
        
        cancelButton.isHidden = !editMode
        confirmButton.isHidden = !editMode
        addTagButton.isHidden = !editMode
        
        addTagLabel.isHidden = !editMode
        tagField.isHidden = !editMode
        
        text.isEnabled = editMode
   
        tagList.enableRemoveButton = editMode
        tagList.removeButtonIconSize = 6
    }
    
    func updateQuestion(){
        
        //get tags from TagListView
        var tags = [String]()
        for tag:TagView in tagList.tagViews {
            tags.append(tag.titleLabel!.text!)
        }
        
        let params = ["newText": text.text!, "newTags": tags, "key": data.key] as [String : Any]
          let urlRoute = Server.hostURL + "/profile/update"
        
        Server.post(urlRoute: urlRoute, params: params, callback: editCallback(data:), errorMessage: "Unable to edit question!")
    }
    
    func editCallback(data:Data) {
        //if there is a response body, then it failed to edit, exit edit mode
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let dict = json as? [String:String]{
                Server.showError(message: dict["message"]!)
                self.loadData()
            }
        } catch {
            //otherwise update the table and close the modal
            modalDelegate.refreshQuestions()
            self.closeModal()
        }
    }

    func closeModal(){
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        if (row != nil){
            modalDelegate.modalClose(row: row)
        }
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
        }
    }
}

