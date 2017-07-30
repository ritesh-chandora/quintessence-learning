//
//  EbookPaywallViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/30/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class EbookPaywallViewController: UIViewController {

    @IBAction func payButton(_ sender: UIButton) {
        Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).child("Ebook").setValue(true)
        let ebook = self.storyboard?.instantiateViewController(withIdentifier: "ebook")
        self.navigationController?.replaceViewController(with: ebook!, animated: true)
    }
}

extension UINavigationController {
    func replaceViewController(with viewController: UIViewController, animated: Bool) {
        var vcs = viewControllers
        vcs[vcs.count - 1] = viewController
        setViewControllers(vcs, animated: animated)
    }
}
