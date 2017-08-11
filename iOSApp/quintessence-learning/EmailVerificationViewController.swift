//
//  EmailVerificationViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 8/4/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class EmailVerificationViewController: UIViewController {

    var email:String?
    var first:String?
    var last:String?
    
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
    
    @IBAction func onContinue(_ sender: UIButton) {
        Auth.auth().currentUser!.reload { (error) in
            if error != nil {
                Server.showError(message: "Could not verify state of user!")
            } else {
                if (Auth.auth().currentUser!.isEmailVerified) {
                    
                    self.createEmail(email:self.email!, first:self.first!, last:self.last!)
                    
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
    
    //handling creation of email in mailchimp to subscribe 
    func createEmail(email:String, first:String, last:String) {
        let fields = ["FNAME":first, "LNAME":last, "STATUS":"trial"]
        let params = ["email_address":email, "status":"pending", "merge_fields":fields] as [String : Any]
        let urlRoute = Server.mailChimpURL + "lists/" + PrivateConstants.list_id + "/members"
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
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let dict = json as? [String:Any] {
                        let id = dict["id"] as? String ?? nil
                        if (id != nil) {
                            Database.database().reference().child(Common.USER_PATH).child(Auth.auth().currentUser!.uid).child("Email_UD").setValue(id)
                        }
                    }
                } catch {
                    Server.showError(message: "Unable to subscribe email!")
                }
            }
            }.resume()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailText!.text = email
    }


}
