//
//  ProfileViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/25/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import UserNotifications
class ProfileViewController: UITableViewController {
    
    private var timePickerVisible = false
    static var notifyTime:Date?
    var user:User?
    var premium = false
    var ref:DatabaseReference?
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var changeUserEmail: UILabel!
    @IBOutlet weak var changePass: UILabel!
    @IBOutlet weak var changeNotif: UILabel!
    @IBOutlet weak var changePayment: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        dateFormatter.timeStyle = .short
        //set value of time label
        if (time != nil){
            ref!.child(Common.USER_PATH).child(user!.uid).child("Time").observeSingleEvent(of: .value, with: { (notifyTime) in
                let timeToShow = Date(timeIntervalSince1970: notifyTime.value as? TimeInterval ?? 0)
                self.time.text = self.dateFormatter.string(from: timeToShow)
            })
        }
        
        ref!.child(Common.USER_PATH).child(user!.uid).child("Type").observeSingleEvent(of: .value, with: { (snapshot) in
            let type = snapshot.value as? String ?? ""
            if ((type == "premium")) {
                if (!SubscriptionService.shared.hasReceiptData!) {
                    self.premium = false
                } else {
                    self.premium = true
                }
            } else {
                self.premium = false
            }
            if (self.premium && self.changePayment.text != nil) {
                self.changePayment.text = "Manage subscription (Opens iTunes)"
            } else {
                self.changePayment.text = "Upgrade to Premium"
            }
        })
    }
    
    
    override func viewDidLoad() {
        user = Auth.auth().currentUser!
        ref = Database.database().reference()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        switch(section) {
            case 0:
                if (indexPath.row == 1){
                    
                    //present login screen
                    let ac = UIAlertController(title: "Login", message: "This action requires you to re-login", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
                    ac.addTextField(configurationHandler: { (_ textField: UITextField) in
                        textField.placeholder = "Email"
                    })
                    
                    ac.addTextField(configurationHandler: { (_ textField: UITextField) in
                        textField.placeholder = "Password"
                        textField.isSecureTextEntry = true
                    })
                    
                    //handle reauthentication
                    ac.addAction(UIAlertAction(title: "Login", style: .default, handler: { (_ sender:UIAlertAction) in
                        let credentials = EmailAuthProvider.credential(withEmail: ac.textFields![0].text!, password: ac.textFields![1].text!)
                        self.user!.reauthenticate(with: credentials, completion: { (error) in
                            if let error = error {
                                Server.showError(message: error.localizedDescription)
                            } else {
                                //if successful reauth, show the change dialog
                                self.showConfirmationDialog(title: "Change Password...", placeholder: "Enter password...", isPrivate: true, handler: { (newString:String) in
                                    self.user!.updatePassword(to: newString, completion: { (_ error:Error?) in
                                        if let error = error {
                                            Server.showError(message: error.localizedDescription)
                                        } else {
                                            Common.showSuccess(message: "Password Updated Successfully!")
                                            tableView.deselectRow(at: indexPath, animated: true)
                                        }
                                    })
                                })
                            }
                        })
                    }))
                    present(ac, animated:  true)

                }
            break
            case 1:
                if (self.premium) {
                    //change notif
                    let timeChangeView = self.storyboard?.instantiateViewController(withIdentifier: "TimeChange") as? NewTimeViewController
                    timeChangeView!.row = indexPath
                    timeChangeView!.modalDelegate = self
                    timeChangeView!.timeLabelDelegate = self
                    timeChangeView!.modalPresentationStyle = .overFullScreen
                    self.navigationController?.present(timeChangeView!, animated: true)
                } else {
                    let premiumVC = self.storyboard?.instantiateViewController(withIdentifier: "Premium") as! PremiumPurchaseViewController
                    premiumVC.basicIsHidden = true
                    self.navigationController?.pushViewController(premiumVC, animated: true)
                }
                break
            case 2:
                //payment settings
                if (indexPath.row == 0){
                    if (!premium) {
                        let premiumVC = self.storyboard?.instantiateViewController(withIdentifier: "Premium") as! PremiumPurchaseViewController
                        premiumVC.basicIsHidden = true
                        self.navigationController?.pushViewController(premiumVC, animated: true)
                    } else {
                        UIApplication.shared.open(URL(string: "itms-apps://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")!, options: [:], completionHandler: nil)
                    }
                }
                break
            case 3:
                //logout section
                showLogout()
                break
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //PASSWORD
    //displays an alert controller with two textfields,
    func showConfirmationDialog(title:String, placeholder:String, isPrivate:Bool, handler:@escaping (_ newString:String) -> Void){
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: { (_ textField: UITextField) -> Void in
            textField.placeholder = placeholder
            textField.isSecureTextEntry = isPrivate
        })
        
        ac.addTextField(configurationHandler: { (_ textField: UITextField) -> Void in
            textField.placeholder = "Confirm..."
            textField.isSecureTextEntry = isPrivate
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        ac.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_action:UIAlertAction) in
            if (ac.textFields![0].text! != ac.textFields![1].text!){
                //throw error if fields do not match
                DispatchQueue.main.async {
                    Server.showError(message: "Fields do not match!")
                    self.present(ac, animated: true, completion: nil)
                }
            } else {
                handler(ac.textFields![0].text!)
            }
        }))
        present(ac, animated: true)
    }
    
    
    //LOGOUT FUNCTION
    
    func showLogout(){
        let ac = UIAlertController(title: "Confirm", message: "Are you sure you want to log out?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (action) in
            do {
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
                
                try Auth.auth().signOut()
                let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! UINavigationController
                self.navigationController!.present(welcomeScreen, animated: true)
            } catch {
                Server.showError(message: error.localizedDescription)
            }
        }
        ))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

extension ProfileViewController : ModalDelegate {
    func refreshQuestions() {
        return
    }
    
    func modalClose(row: IndexPath) {
        tableView.deselectRow(at: row, animated: true)
    }
}

extension ProfileViewController : UpdateTimeLabel {
    func updateTimeLabel(newDate: Date) {
        self.time.text = dateFormatter.string(from: newDate)
    }
}

