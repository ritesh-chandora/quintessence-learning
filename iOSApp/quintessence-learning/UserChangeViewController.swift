//
//  UserChangeViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/28/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class UserChangeViewController: ProfileViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var joinLabel: UILabel!
    @IBOutlet weak var uidLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = SubscriptionService.shared.loadReceipt()
        getUserData()
        self.tableView.separatorColor = UIColor.clear
    }
    
    //populates user data (name, email, join date, account type)
    func getUserData(){
        self.ref!.child(Common.USER_PATH).child(self.user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let userInfo = snapshot.value as? NSDictionary
            if let userInfo = userInfo {
                self.nameLabel.text! = userInfo["Name"] as! String
                self.emailLabel.text! = userInfo["Email"] as! String
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                let joinDateSinceEpoch = userInfo["Join_Date"] as! TimeInterval
                //Firebase uses milliseconds while Swift uses seconds, need to do conversion
                let joinDate = Date(timeIntervalSince1970: (joinDateSinceEpoch/1000))
                self.joinLabel.text! = dateFormatter.string(from: joinDate)
                let type = userInfo["Type"] as! String
                if (type == "premium_trial") {
                    //calculate number of days left in trial
                    print(joinDate.timeIntervalSince1970)
                    print(Date().timeIntervalSince1970)
                    print(Int((Date().timeIntervalSince1970 - joinDate.timeIntervalSince1970)/Common.dayInSeconds))
                    let numDays = Common.trialLength - Int((Date().timeIntervalSince1970 - joinDate.timeIntervalSince1970)/Common.dayInSeconds)
                    self.typeLabel.text! = "Free Trial (\(numDays) days left)" 
                } else if (type == "premium"){
                    //TODO add days remaining in subscription
                    self.typeLabel.text! = "Premium, Expires \(dateFormatter.string(from: Date(timeIntervalSince1970: Common.expireDate)))"
                } else {
                    self.typeLabel.text! = "Basic"
                }
                let uidString = userInfo["UID"] as! String
                self.uidLabel.text = uidString
                
            } else {
                Server.showError(message: "Unable to retrieve user info!")
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                //change name
                let ac = UIAlertController(title: "Change name...", message: nil, preferredStyle: .alert)
                ac.addTextField(configurationHandler: { (_ textField: UITextField) -> Void in
                    textField.placeholder = "Enter new name here..."
                })
                
                ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) in
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }))
                
                ac.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_action:UIAlertAction) in
                    self.ref!.child(Common.USER_PATH).child(self.user!.uid).child("Name").setValue(ac.textFields![0].text!)
                    self.getUserData()
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }))
                
                present(ac, animated: true)
            } else {
                //change email
                let ac = UIAlertController(title: "Login", message: "This action requires you to re-login", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: {(action) in
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }))
                
                ac.addTextField(configurationHandler: { (_ textField: UITextField) in
                    textField.placeholder = "Email"
                })
                
                ac.addTextField(configurationHandler: { (_ textField: UITextField) in
                    textField.placeholder = "Password"
                    textField.isSecureTextEntry = true
                })
                
                ac.addAction(UIAlertAction(title: "Login", style: .default, handler: { (_ sender:UIAlertAction) in
                    let credentials = EmailAuthProvider.credential(withEmail: ac.textFields![0].text!, password: ac.textFields![1].text!)
                    self.user!.reauthenticate(with: credentials, completion: { (error) in
                        if let error = error {
                            Server.showError(message: error.localizedDescription)
                            self.tableView.deselectRow(at: indexPath, animated: true)
                        } else {
                            //if successful reauth, show the change dialog
                            self.showConfirmationDialog(title: "Change Email...", placeholder: "Enter email...", isPrivate: false, handler: { (newString:String) in
                                self.user!.updateEmail(to: newString, completion: { (_ error:Error?) in
                                    if let error = error {
                                        Server.showError(message: error.localizedDescription)
                                    } else {
                                        //if updated sucessfully, do the same in the Users table
                                        self.ref!.child(Common.USER_PATH).child(self.user!.uid).child("Email").setValue(newString)
                                        Common.showSuccess(message: "Email Updated Successfully!")
                                        self.getUserData()
                                        tableView.deselectRow(at: indexPath, animated: true)
                                    }
                                })
                            })
                        }
                    })
                }))
                present(ac, animated:  true)
            }
        }
    }
}
