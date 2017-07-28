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
    
    static var notifyTime:Date?
    
    @IBOutlet weak var changeUserEmail: UILabel!
    @IBOutlet weak var changePass: UILabel!
    @IBOutlet weak var changeNotif: UILabel!
    @IBOutlet weak var viewPayment: UILabel!
    @IBOutlet weak var changePayment: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    
    @IBOutlet weak var logoutIcon: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        switch(section) {
            case 1:
                //change notif
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
    
    
    //LOGOUT FUNCTION
    
    func showLogout(){
        let ac = UIAlertController(title: "Confirm", message: "Are you sure you want to log out?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Logout", style: .default, handler: logout(action: )))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func logout(action:UIAlertAction){
        do {
            try Auth.auth().signOut()
            let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! UINavigationController
            self.navigationController!.present(welcomeScreen, animated: true)
        } catch {
            Server.showError(message: error.localizedDescription)
        }
    }
}
