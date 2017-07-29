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

   
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //change name
            let ac = UIAlertController(title: "Change name...", message: nil, preferredStyle: .alert)
            ac.addTextField(configurationHandler: { (_ textField: UITextField) -> Void in
                textField.placeholder = "Enter new name here..."
            })
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            
            ac.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_action:UIAlertAction) in
                self.ref!.child(Common.USER_PATH).child(self.user!.uid).child("Name").setValue(ac.textFields![0].text!)
            }))
            
            present(ac, animated: true)
        } else {
            //change email
            
            let ac = UIAlertController(title: "Login", message: "This action requires you to re-login", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
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