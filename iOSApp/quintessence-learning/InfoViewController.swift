//
//  InfoViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 8/14/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var text1: UITextView!
    
    @IBOutlet weak var text2: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //make the text view start at the top, always
        text2.setContentOffset(CGPoint.zero, animated: false)
        text1.setContentOffset(CGPoint.zero, animated: false)
    }
}
