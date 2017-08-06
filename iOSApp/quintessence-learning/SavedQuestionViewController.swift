//
//  SavedQuestionViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/24/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import TagListView
import FirebaseDatabase
import FirebaseAuth
class SavedQuestionViewController: ModalViewController {

    var ref:DatabaseReference?
    var user:String?
    var isSaved = false
    var key:String?
    
    @IBOutlet weak var questionText: UITextView!
    @IBOutlet weak var tagsView: TagListView!
    @IBOutlet weak var saveButton: UIButton!
    
    //saves the question
    @IBAction func onSave(_ sender: UIButton) {
        if (isSaved) {
            ref!.child("Saved").child(key!).removeValue()
            DispatchQueue.main.async {
                self.saveButton.setTitle("Save", for: .normal)
            }
            self.isSaved = false
        } else {
            self.ref!.child("Saved").updateChildValues([key!:true])
            DispatchQueue.main.async {
                self.saveButton.setTitle("Unsave", for: .normal)
            }
            self.isSaved = true
        }
    }
    @IBAction override func onClose(_ sender: UIButton) {
        super.onClose(sender)
    }
    
    override func viewDidLoad() {
        user = Auth.auth().currentUser!.uid
        ref = Database.database().reference().child(Common.USER_PATH).child(user!)
        
        DispatchQueue.main.async { [unowned self] in
            self.questionText.text! = self.data!.text
            self.tagsView.removeAllTags()
            self.tagsView.addTags(self.data!.tags)
        }
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isOpaque = false
        
        key = self.data.key
        
        //initially sets if the question is saved or not (this can be accessed by past question
        ref!.child("Saved").queryOrderedByKey().queryEqual(toValue: key!).observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.exists()
            if(data){
                DispatchQueue.main.async {
                    self.saveButton.setTitle("Unsave", for: .normal)
                }
                self.isSaved = true
            }
        })
        
    }


}
