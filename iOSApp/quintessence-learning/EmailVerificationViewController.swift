//
//  EmailVerificationViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 8/4/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
class EmailVerificationViewController: UIViewController {

    var email:String?
    
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
    
    @IBAction func onContinue(_ sender: UIButton) {
        Auth.auth().currentUser!.reload { (error) in
            if let error = error {
                Server.showError(message: "Could not verify state of user!")
            } else {
                if (Auth.auth().currentUser!.isEmailVerified) {
                    let welcomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
                    self.present(welcomeScreen, animated: true)
                } else {
                    Server.showError(message: "Please verify your email!")
                }
            }
        }
        
    }
    
    @IBAction func onResend(_ sender: UIButton) {
        Auth.auth().currentUser!.sendEmailVerification { (error) in
            if let error = error {
                Server.showError(message: error.localizedDescription)
            } else {
                Common.showSuccess(message: "Email verification sent!")
            }
        }
    }
    
    func toggleButtons(toggle:Bool){
        continueButton.isEnabled = toggle
        resendButton.isEnabled = toggle
        if (!toggle) {
            continueButton.setTitle("Loading...", for: .normal)
        } else {
            continueButton.setTitle("Continue", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailText!.text = email
    }


}
