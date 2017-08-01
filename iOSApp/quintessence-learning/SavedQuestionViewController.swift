//
//  SavedQuestionViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/24/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import TagListView
class SavedQuestionViewController: ModalViewController {

    @IBOutlet weak var questionText: UITextView!
    @IBOutlet weak var tagsView: TagListView!
    
    @IBAction override func onClose(_ sender: UIButton) {
        super.onClose(sender)
    }
    
    override func viewDidLoad() {
        DispatchQueue.main.async { [unowned self] in
            self.questionText.text! = self.data!.text
            self.tagsView.removeAllTags()
            self.tagsView.addTags(self.data!.tags)
        }
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isOpaque = false
    }


}
