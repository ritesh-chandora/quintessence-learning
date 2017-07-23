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
    
    static let hostURL = "http://localhost:3001"
    
    let loginUrl = hostURL + "/login"
    let signupUrl = hostURL + "/signup"
    
    @IBAction func loginPress(_ sender: UIButton) {
        userPostReq(urlRoute: loginUrl)
    }
    
    @IBAction func registerPress(_ sender: UIButton) {
        userPostReq(urlRoute: signupUrl)
    }
    
    //do POST request to proper login route (login or signup)
    func userPostReq(urlRoute: String){
        
        //serialize params into JSON
        let params = ["email": emailText!.text!, "password": passField!.text!]
        guard let reqBody = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        
        //set up POST request
        guard let url = URL(string: urlRoute) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = reqBody
        
        
        //excute POST request
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
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
                                    let console = self.storyboard?.instantiateViewController(withIdentifier: "Admin") as! UITabBarController
                                    self.present(console, animated: true, completion: nil)
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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
