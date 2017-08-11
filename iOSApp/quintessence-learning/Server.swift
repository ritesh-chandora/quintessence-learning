//
//  Server.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/24/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit

class Server: NSObject {
    
    static let hostURL = "https://us-central1-test-project-692ad.cloudfunctions.net/"
    static let mailChimpURL = "https://us16.api.mailchimp.com/3.0/"
    
    
    typealias callbackFunc = (_ data:Data) throws -> Void
    
    static func post(urlRoute: String, params:[String:Any], callback:@escaping callbackFunc, errorMessage:String){

        
        //serialize params into JSON
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
                    try callback(data)
                } catch {
                    debugPrint("fuck")
                    showError(message: errorMessage)
                }
            }
        }.resume()
        
    }
    
    //displays an error
    static func showError(message:String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindowLevelAlert + 1;
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(ac, animated: true, completion: nil)
        }
    }
}
