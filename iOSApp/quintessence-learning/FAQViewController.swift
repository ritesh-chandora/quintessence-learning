//
//  FAQViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 8/11/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FAQView
class FAQViewController: UIViewController {

    var faqView: FAQView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "FAQs"
        self.automaticallyAdjustsScrollViewInsets = false
        let items = [
            FAQItem(question: "What happens if I miss a day or two?", answer: "If you miss a set of questions, you can view them in past questions by navigating to \"Questions\" tab, then tapping the folder icon in the top right and then tapping \"View past questions\"."),
            FAQItem(question: "How can I view past questions?", answer: "Past questions can be viewed by pressing the folder icon in the top right corner under the \"Questions\" Tab. "),
            FAQItem(question: "How does changing notification time work?", answer: "This is a premium feature only, as you will receive daily sets of questions. Once the time is changed, the current notification time will be kept for one more set of questions. Then the questions will come at the new specified time. The notifications will take 24 hours to register properly."),
            FAQItem(question: "When do I receive questions?", answer:"If you have a premium account, you will receive one set of three questions once a day at the time you specified. Otherwise, with a basic account, you will receive only one set of three questions per week at day and time you specified. No questions will be sent on the weekends."),
            FAQItem(question: "How do I access the E-book?", answer:"The E-book is included with an account. Pressing on \"E-book\" will direct to you a password-protected page. The password will be sent to you in an initial welcome email.")]
    faqView = FAQView(frame: view.frame, items: items)
        faqView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(faqView)
        addFaqViewConstraints()
    }
    
    func addFaqViewConstraints() {
        let faqViewTrailing = NSLayoutConstraint(item: faqView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailingMargin, multiplier: 1, constant: 17)
        let faqViewLeading = NSLayoutConstraint(item: faqView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leadingMargin, multiplier: 1, constant: -17)
        let faqViewTop = NSLayoutConstraint(item: faqView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 50)
        let faqViewBottom = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: faqView, attribute: .bottom, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([faqViewTop, faqViewBottom, faqViewLeading, faqViewTrailing])
    }
}
