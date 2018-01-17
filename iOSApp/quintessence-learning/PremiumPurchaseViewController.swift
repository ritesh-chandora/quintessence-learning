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
import UserNotifications
import WebKit
class PremiumPurchaseViewController: UIViewController, SKPaymentTransactionObserver  {

    @IBOutlet weak var premiumButton: UIButton!
    @IBOutlet weak var basicButton: UIButton!
    
    var basicIsHidden = false
    var ref:DatabaseReference?
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        SKPaymentQueue.default().add(self)
        if (user != nil) {
            ref = Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid)
            if (basicIsHidden) {
                basicButton.isHidden = true
            }
        }
    }
    @IBAction func termsOfService(_ sender: UIButton) {
        let pUrl = URL(string: "http://familyhuddles.com/terms/")
        if let pUrl = pUrl {
            let pView = self.storyboard?.instantiateViewController(withIdentifier: "ebook")
            
            let webView = WKWebView(frame: pView!.view.frame)
            let urlRequest = URLRequest(url: pUrl)
            webView.load(urlRequest)
            
            pView!.view.addSubview(webView)
            
            self.navigationController?.pushViewController(pView!, animated: true)
        }

    }
    
    @IBAction func privacyPolicyLink(_ sender: UIButton) {
        let pUrl = URL(string: "http://familyhuddles.com/privacy/")
        if let pUrl = pUrl {
            let pView = self.storyboard?.instantiateViewController(withIdentifier: "ebook")
            
            let webView = WKWebView(frame: pView!.view.frame)
            let urlRequest = URLRequest(url: pUrl)
            webView.load(urlRequest)
            
            pView!.view.addSubview(webView)
            
            self.navigationController?.pushViewController(pView!, animated: true)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        SKPaymentQueue.default().remove(self)
    }

    func toggleButtons(toggle:Bool){
        premiumButton.isEnabled = toggle
        basicButton.isEnabled = toggle
        if (!toggle){
            premiumButton.setTitle("Processing...", for: .normal)
        } else {
            premiumButton.setTitle("Purchase Premium or Restore", for: .normal)
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
            case .restored:
                handleRestoredState(for: transaction, in: queue)
                showUserPanel()
            case .failed:
                toggleButtons(toggle: true)
                print("wtf")
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
        print("purchasing...")
        SubscriptionService.shared.uploadReceipt { (success) in
            
        }
    }
    
    func handlePurchasedState(for transaction:SKPaymentTransaction, in queue: SKPaymentQueue){
        
        Common.timeInterval = Common.dayInSeconds
        print("purchased!")
        queue.finishTransaction(transaction)
        queue.remove(self)
        
        SubscriptionService.shared.hasReceiptData = true
        print("success!")
        
        //change state in firebase
        self.ref!.child("Type").setValue("premium")
        //change state in mailchimp
        self.updateEmail(premium: true)
        
        //give the user a question and set the local notific
        updateTime()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userViewController = storyboard.instantiateViewController(withIdentifier: "User") as! UITabBarController
        self.present(userViewController, animated: true)
        
        //Above UpdateTime function is already setting the notifications. No need to set it again.
        //set local notification timer
//        let center = UNUserNotificationCenter.current()
//        center.removeAllPendingNotificationRequests()
//        ref!.child("Time").observeSingleEvent(of: .value, with: { (value) in
//            let time = value.value as! TimeInterval
//            let currTime = Date(timeIntervalSince1970: time)
//            //Common.setNotificationTimer(date: currTime, isRepeating: true, repeatingDays: nil)
//            //Common.setNotificationTimer(date: currTime, repeating: true, daily: true)
//
//        })
        SubscriptionService.shared.uploadReceipt { (success) in
            
        }
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        queue.remove(self)
        
        //set local notification timer
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        

        self.ref!.child("Time").observeSingleEvent(of: .value, with: { (time) in
             self.ref!.child("NotificationDays").observeSingleEvent(of: .value, with: { (notiDays) in
                let time = time.value as! TimeInterval
                let time_Date = Date(timeIntervalSince1970: time)
                
                let notifyDays = notiDays.value as! String
                
                //Common.setNotificationTimer(date: newTime!, repeating: true, daily: true)
                Common.setNotificationTimer(date: time_Date, isRepeating: true, repeatingDays: notifyDays.components(separatedBy: ",").map({ (x:String) -> Int in return Int(x)! }))
            })
        })


        SubscriptionService.shared.uploadReceipt { (success) in
        }
    }
    
    @IBAction func purchasePremium(_ sender: UIButton) {
        toggleButtons(toggle: false)
        SubscriptionService.shared.purchase(product: Common.PREMIUM_ID)
    }
    
    @IBAction func continueBasic(_ sender: UIButton) {
        let ac = UIAlertController(title: "Confirm", message: "Continue with a basic account?", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
            
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()

            self.ref!.child("Type").setValue("basic")
            self.updateEmail(premium: false)
            //Common.timeInterval = Common.weekInSeconds
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
            request.httpMethod = "PUT"
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
    
    //updates the time from basic -> premium, plus gives an immediate question to satisfy App Store Guidelines
    func updateTime(){
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        Database.database().reference(withPath: ".info/serverTimeOffset").observeSingleEvent(of: .value, with: { dateSnapShot in
            if let offset = dateSnapShot.value as? TimeInterval {
                let currentTimeStamp = (Date().timeIntervalSince1970*1000 + offset) / 1000 //GetItFromServer
                print("Preimum Purchase UpdateTime CurrentTimeStamp \(currentTimeStamp)")
                
                self.ref!.child("Time").observeSingleEvent(of: .value, with: { (value) in
                    let time = value.value as! TimeInterval
                    //let currTime = Date().timeIntervalSince1970 // Removed.
                    
                    //automatically give user a new question
                    self.ref!.child("Old_Time").setValue(currentTimeStamp)
                    
                    let OldNotifyDays = [1,1,1,1,1,1,1] // anyway this is going to be deleted. But need to make sure user get some kind of notification
                    self.ref!.child("Old_NotificationDays").setValue(OldNotifyDays.map(String.init).joined(separator: ","))
                    
                    let calendar = Calendar.current
                    let comp = calendar.dateComponents([.hour, .minute], from: Date(timeIntervalSince1970: time))
                    let hour = comp.hour
                    let minute = comp.minute
                    let notifyDays = [0,1,1,1,1,1,0]
                    
                    var newTime = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                    newTime = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: newTime!)
                    //Common.setNotificationTimer(date: newTime!, repeating: true, daily: true)
                    Common.setNotificationTimer(date: newTime!, isRepeating: true, repeatingDays: notifyDays)
                    
                    self.ref!.child("Time").setValue(newTime?.timeIntervalSince1970)
                    
                    
                    self.ref!.child("NotificationDays").setValue(notifyDays.map(String.init).joined(separator: ","))
                })
            }
        })
        
    }
}
