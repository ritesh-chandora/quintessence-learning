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
class ProfileViewController: UITableViewController {
    
    private var timePickerVisible = false
    static var notifyTime:Date?
    var user:User?
    var ref:DatabaseReference?
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var changeUserEmail: UILabel!
    @IBOutlet weak var changePass: UILabel!
    @IBOutlet weak var changeNotif: UILabel!
    @IBOutlet weak var viewPayment: UILabel!
    @IBOutlet weak var changePayment: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var time: UILabel!
    
    @IBAction func timePickerChange(_ sender: Any) {
        defaults.set(timePicker.date, forKey: "NotifyTime")
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        //TODO check when to next show question
        
        time.text = dateFormatter.string(from: timePicker.date)
    }
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notifyTime = defaults.object(forKey: "NotifyTime") as! Date
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        time.text = dateFormatter.string(from: notifyTime)
        
        user = Auth.auth().currentUser!
        ref = Database.database().reference()
    }
    
    //adjusts height for table show/hide picker
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !timePickerVisible && indexPath.section == 1 && indexPath.row == 1 {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
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
                //change notif
                timePickerVisible = !timePickerVisible
                tableView.beginUpdates()
                tableView.endUpdates()
                tableView.deselectRow(at: indexPath, animated: true)
                break
            case 2:
                //payment settings
                if (indexPath.row == 1){
                    //view payment history
                }
                break
            case 3:
                //logout section
                showLogout()
                break
        default:
            break
        }
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
    
    //NOTIFICATION TIMER
    
    //set the notification cell to display a time picker
    
    
    //LOGOUT FUNCTION
    
    func showLogout(){
        let ac = UIAlertController(title: "Confirm", message: "Are you sure you want to log out?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (action) in
            do {
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
