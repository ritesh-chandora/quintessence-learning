//
//  LoginHandlerViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/19/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit

class LoginHandlerViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    @IBOutlet weak var test: UILabel!
    
    let loginUrl = "http://localhost:3001/login"
    let signupUrl = "http://localhost:3001/signup"
    
    @IBAction func loginPress(_ sender: UIButton) {
        if (emailText!.text! == ""){
            return
        }
        if (passField!.text! == ""){
            return
        }
        let params = ["email": emailText!.text!, "password": passField!.text!]
        
        let url = URL(string: loginUrl)
        if let url = urlString {
            let login = URLSession.shared.dataTask(with: <#T##URL#>)
        }
    }
    
    @IBAction func registerPress(_ sender: UIButton) {
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
