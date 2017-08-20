//
//  PremiumFAQViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 8/11/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FAQView
class PremiumFAQViewController: UIViewController {
    
    var faqView: FAQView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About Premium"
        self.automaticallyAdjustsScrollViewInsets = false
        let items = [
            FAQItem(question: "What is premium?", answer: "Premium is our upgraded, auto-renewing subscription membership that delivers sets of questions daily rather than weekly. As a result, you will receive ~60 questions a month, versus the ~12 questions a month with basic. You will also gain access to change your notification time as well. THe length of the premium subscription is one month, autorenewing."),
             FAQItem(question: "What is an auto-renewable subscription?", answer:"An auto-renewing subscription will automatically renew at the end of your subscription term, or in this case, at the end of the month. You will be automatically charged at the end of the month without worrying about the subscription expiring. You many cancel your subscription or turn off auto-renewal up to 24 hours before the next month."),
            FAQItem(question: "What happens if I am still on my premium trial?", answer: "You will forfeit the rest of the trial and begin the premium membership immediately."),
            FAQItem(question: "How does payment work?", answer: "Family Huddles will charge you through your iTunes Account, and upon pressing the purchase button, iTunes will confirm your purchase. Note that this subscription is auto-renewing, so you will not need to resubscribe every month; you will automatically be charged."),
            FAQItem(question: "What if I want to cancel/manage my subscription?", answer: "You may cancel/manage your subscription through the App Store or iTunes. You may also turn off auto-renewing by navigating to your Account Settings after purchasing. You will have up to 24 hours before the renew date to turn off auto-renewing or to cancel the next month. Once you subscribe, there will be an option in Family Huddles' to manage subscriptions.")]
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
