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

class ModalViewController: UIViewController, TagListViewDelegate {
    
    @IBOutlet weak var text: UITextField!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var addTagLabel: UILabel!
    
    @IBOutlet weak var tagList: TagListView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addTagButton: UIButton!
    
    //handles adding tag
    @IBAction func onAddTag(_ sender: Any) {
        if (tagField.text!.characters.count > 0) {
            tagList.addTag(tagField.text!)
            tagField.text! = ""
        } else {
            showError(message: "Input a tag!")
        }
        
    }
    
    //activates edit mode
    @IBAction func onEdit(_ sender: UIButton) {
        configButtons(editMode: true)
    }
    
    //confirms edits, will push to server and reload table data
    @IBAction func onConfirm(_ sender: UIButton) {
        configButtons(editMode: false)
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
        tagList.delegate = self
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
    }

    //loads default data
    func loadData(){
        text.text! = data!.text
        tagList.removeAllTags()
        tagList.addTags(data!.tags)
    }
    
    //configures the buttons to enter edit mode or exit
    func configButtons(editMode:Bool){
        closeButton.isEnabled = !editMode
        closeButton.isHidden = editMode
        editButton.isHidden = editMode
        
        cancelButton.isHidden = !editMode
        confirmButton.isHidden = !editMode
        addTagButton.isHidden = !editMode
        
        addTagLabel.isHidden = !editMode
        tagField.isHidden = !editMode
        
        text.isEnabled = editMode
   
        tagList.enableRemoveButton = editMode
        tagList.removeButtonIconSize = 6
    }
    
    func updateQuestion(){
        
        //get tags from TagListView
        var tags = [String]()
        for tag:TagView in tagList.tagViews {
            tags.append(tag.titleLabel!.text!)
        }
        
        let params = ["newText": text.text!, "newTags": tags, "key": data.key] as [String : Any]
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
                    //if there is a response body, then it failed to edit, exit edit mode
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                        if let dict = json as? [String:String]{
                            DispatchQueue.main.async {
                                self.showError(message: dict["message"]!)
                            }
                            self.loadData()
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
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
        }
    }
}

