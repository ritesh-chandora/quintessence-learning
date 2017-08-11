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
class PremiumPurchaseViewController: UIViewController, SKPaymentTransactionObserver  {

    @IBOutlet weak var premiumButton: UIButton!
    @IBOutlet weak var basicButton: UIButton!
    var basicIsHidden = false
    var ref:DatabaseReference?
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid)
        SKPaymentQueue.default().add(self)
        if (basicIsHidden) {
            basicButton.isHidden = true
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased:
                handlePurchasedState(for: transaction, in: queue)
                showUserPanel()
                break
            case .restored:
                handleRestoredState(for: transaction, in: queue)
                showUserPanel()
                //            case .failed:
            //                handleFailedState(for: transaction, in: queue)
            default:
                break
            }
        }
    }
    
    func showUserPanel(){
        let userViewController = self.storyboard?.instantiateViewController(withIdentifier: "User") as! UITabBarController
        self.present(userViewController, animated: true)
    }
    
    func handlePurchasingState(for transaction:SKPaymentTransaction, in queue: SKPaymentQueue){
        //change state in firebase
        self.ref!.child("Type").setValue("premium")
        //change state in mailchimp
        updateEmail(premium: true)
        
        print("purchasing...")
        Common.timeInterval = Common.dayInSeconds
        updateTime()
        SubscriptionService.shared.uploadReceipt { (success) in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: SubscriptionService.purchaseSuccessfulNotification, object: nil)
            }
        }
    }
    
    func handlePurchasedState(for transaction:SKPaymentTransaction, in queue: SKPaymentQueue){
        
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
    
    @IBAction func purchasePremium(_ sender: UIButton) {
        SubscriptionService.shared.purchase(product: Common.PREMIUM_ID)
    }
    
    @IBAction func continueBasic(_ sender: UIButton) {
        let ac = UIAlertController(title: "Confirm", message: "Continue with a basic account?", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
            self.ref!.child("Type").setValue("basic")
            self.updateEmail(premium: false)
            Common.timeInterval = Common.weekInSeconds
            let basicVC = self.storyboard?.instantiateViewController(withIdentifier: "Basic") as! BasicWelcomeViewController
            self.present(basicVC, animated: true)
        }))
        
        present(ac, animated: true)
    }
    
    //sets status to "Premium" in mailchimp
    func updateEmail(premium:Bool){
        
        let status = premium ? "premium" : "basic"
        
        let fields = ["STATUS": status]
        let params = ["merge_fields":fields] as [String : Any]
        
        self.ref!.child("Email_ID").observeSingleEvent(of: .value, with: { (email) in
            let id = email.value as? String ?? nil
            if (id == nil) {return}
            let urlRoute = Server.mailChimpURL + "lists/" + PrivateConstants.list_id + "/members/" + id!
            print(urlRoute)
            //serialize params into JSON
            guard let reqBody = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
            
            //set up POST request
            guard let url = URL(string: urlRoute) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue(PrivateConstants.mailChimpApiHeader, forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = reqBody
            print(params)
            
            //excute POST request
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                
                }.resume()
        })
    }
    
    func updateTime(){
        self.ref!.child("Time").observeSingleEvent(of: .value, with: { (value) in
            let time = value.value as! TimeInterval
            let currTime = Date().timeIntervalSince1970
            
            //automatically give user a new question
            self.ref!.child("Old_Time").setValue(currTime)
            let calendar = Calendar.current
            let comp = calendar.dateComponents([.hour, .minute], from: Date(timeIntervalSince1970: time))
            let hour = comp.hour
            let minute = comp.minute
            var newTime = Calendar.current.date(byAdding: .day, value: 0, to: Date())
            newTime = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: newTime!)
            self.ref!.child("Time").setValue(newTime?.timeIntervalSince1970)
        })
    }
}
