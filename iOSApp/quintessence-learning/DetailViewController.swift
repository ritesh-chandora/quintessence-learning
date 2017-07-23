//
//  DetailViewController.swift
//  quintessence-learning
//
//  Created by Eric Feng on 7/21/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import TagListView

protocol UpdateQuestionDelegate {
    func refreshQuestions()
}

class ModalViewController: UIViewController {
    
    @IBOutlet weak var text: UITextField!
    @IBOutlet weak var tagList: TagListView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    //activates edit mode
    @IBAction func onEdit(_ sender: UIButton) {
        configButtons(editMode: true)
    }
    
    //confirms edits, will push to server and reload table data
    @IBAction func onConfirm(_ sender: UIButton) {
        configButtons(editMode: false)
        print("hi")
        updateQuestion()
    }
    
    //cancels the edit, restores to original data
    @IBAction func onCancel(_ sender: UIButton) {
        loadData()
        configButtons(editMode: false)
        
    }
    
    @IBAction func onClose(_ sender: Any) {
        closeModal()
    }
    
    var data : Question!
    var updateDelegate: UpdateQuestionDelegate!
    let hostURL = "http://localhost:3001"
    
    override func viewDidLoad() {
        loadData()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.isOpaque = false
    }

    //loads default data
    func loadData(){
        text.text! = data!.text
        tagList.addTags(data!.tags)
    }
    
    //configures the buttons to enter edit mode or exit
    func configButtons(editMode:Bool){
        closeButton.isEnabled = !editMode
        closeButton.isHidden = editMode
        
        editButton.isHidden = editMode
        cancelButton.isHidden = !editMode
        confirmButton.isHidden = !editMode
        
        text.isEnabled = editMode
    }
    
    func updateQuestion(){
        let params = ["newText": text.text!, "newTags": data.tags, "key": data.key] as [String : Any]
        guard let reqBody = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        
        let urlRoute = self.hostURL + "/profile/update"
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
                    //if there is a response body, then it failed to edit
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                        if let dict = json as? [String:String]{
                            DispatchQueue.main.async {
                                self.showError(message: dict["message"]!)
                            }
                    } else {
                        //otherwise update the table and close the modal
                        self.updateDelegate.refreshQuestions()
                        self.closeModal()
                    }
            } catch {
                print(error)
                }
            }
        }.resume()
    }
    
    func closeModal(){
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    //displays an error
    func showError(message:String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(ac, animated: true, completion: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
