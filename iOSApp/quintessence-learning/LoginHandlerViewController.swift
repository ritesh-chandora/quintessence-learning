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
    @IBOutlet weak var infoText: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    let loginUrl = Server.hostURL + "/login"
    let signupUrl = Server.hostURL + "/signup"
    
    @IBAction func loginPress(_ sender: UIButton) {
        userPostReq(urlRoute: loginUrl)
    }
    
    @IBAction func registerPress(_ sender: UIButton) {
        userPostReq(urlRoute: signupUrl)
    }
    
    //do POST request to proper login route (login or signup)
    
    func userPostReq(urlRoute :String){
        let originalTitle = button.titleLabel!.text!
        button.titleLabel!.text! = "Loading..."
        button.isEnabled = false
        let params = ["email": emailText!.text!, "password": passField!.text!]
        Server.post(urlRoute: urlRoute, params: params, callback: postCallback(_:), errorMessage: "Login failed!")
        button.titleLabel!.text! = originalTitle
        button.isEnabled = true
    }
    
    //callback function when post request is complete
    func postCallback(_ data:Data) throws {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        if let dict = json as? [String:String] {
            
            //get response message
            if let message = dict["message"] {
                
                //display error from server if not success
                if (message != "success"){
                    DispatchQueue.global(qos: .background).async {
                        DispatchQueue.main.async {
                            self.infoText!.text = message
                            self.infoText!.isHidden = false;
                        }
                    }
                }
                    //otherwise present the proper view to user
                else {
                    DispatchQueue.main.async { [unowned self] in
                        let console = self.storyboard?.instantiateViewController(withIdentifier: "Admin") as! UINavigationController
                        self.present(console, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
