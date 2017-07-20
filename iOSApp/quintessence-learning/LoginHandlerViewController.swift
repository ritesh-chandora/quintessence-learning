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
        guard let reqBody = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        
        guard let url = URL(string: loginUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = reqBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let dict = json as? [String:String] {
                        if let message = dict["message"] {
                            print(message)
                            if (message != "success"){
                                DispatchQueue.global(qos: .background).async {
                                    DispatchQueue.main.async {
                                        self.infoText!.text = message
                                        self.infoText!.isHidden = false;
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
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
