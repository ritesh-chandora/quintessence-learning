//
//  PremiumPurchaseViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 8/9/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import StoreKit
import FirebaseAuth
import FirebaseDatabase
class PremiumPurchaseViewController: UIViewController  {

    @IBOutlet weak var premiumButton: UIButton!
    @IBOutlet weak var basicButton: UIButton!
    var basicIsHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
        if (basicIsHidden) {
            basicButton.isHidden = true
        }
    }
    
    @IBAction func purchasePremium(_ sender: UIButton) {
        SubscriptionService.shared.purchase(product: Common.PREMIUM_ID)
    }
    
    @IBAction func continueBasic(_ sender: UIButton) {
        let ac = UIAlertController(title: "Confirm", message: "You can upgrade to premium in account settings", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
            Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).child("Type").setValue("basic")
            Common.timeInterval = Common.weekInSeconds
            //TODO change notifications
            let userViewController = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
            self.present(userViewController, animated: true)
        }))
        
        present(ac, animated: true)
    }
}

extension UIViewController : SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
                        switch transaction.transactionState {
            //            case .purchasing:
            //                handlePurchasingState(for: transaction, in: queue)
                        case .purchased:
                            handlePurchasedState(for: transaction, in: queue)
                            break
                        case .restored:
                            handleRestoredState(for: transaction, in: queue)
            //            case .failed:
            //                handleFailedState(for: transaction, in: queue)
                        default:
                            break
            }
            print("wew!")
        }
    }
    
    func handlePurchasedState(for transaction:SKPaymentTransaction, in queue: SKPaymentQueue){
        //change state in firebase
        Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).child("Type").setValue("premium")
        //change state in mailchimp
        Common.timeInterval = Common.dayInSeconds
        //TODO change notifications
        print("purchased!")
        queue.finishTransaction(transaction)
        SubscriptionService.shared.uploadReceipt { (success) in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
            }
        }
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        SubscriptionService.shared.uploadReceipt { (success) in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: SubscriptionService.restoreSuccessfulNotification, object: nil)
            }
        }
    }
}
