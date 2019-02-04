//
//  LoginViewController.swift
//  iBach
//
//  Created by Petar Jedek on 22.11.18.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Unbox

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var viewForm: UIView!
    
    @IBOutlet var textFieldUsername: UITextField!
    @IBOutlet var textFieldPassword: UITextField!
    
    @IBOutlet var buttonLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewForm.layer.cornerRadius = 20
        
    }
    
    override func viewDidLayoutSubviews() {
        let scrollViewBounds = scrollView.bounds
        //let containerViewBounds = contentView.bounds
        
        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = scrollViewBounds.size.height / 2.0
        scrollViewInsets.top -= contentView.bounds.size.height / 2.0
        
        scrollViewInsets.bottom  = scrollViewBounds.size.height/2.0
        scrollViewInsets.bottom -= contentView.bounds.size.height/2.0
        scrollViewInsets.bottom += 1
        
        scrollView.contentInset = scrollViewInsets
    }
    
    @IBAction func loginUser(_ sender: Any) {
        
        if (textFieldUsername.text!.isEmpty || textFieldPassword.text!.isEmpty) {
            
            DispatchQueue.main.async {
                self.printAlert(title: "Information required", message: "Please submit all input fields before submitting the form.")
            }
            
        } else {
            let username = textFieldUsername.text!
            let password = textFieldPassword.text!.hash
            
            let parameters: Parameters = [
                "username": username,
                "password": String(password)
                ] 
            
            HTTPRequest().sendPostRequest(urlString: "https://botticelliproject.com/air/api/user/login.php", parameters: parameters, completionHandler: {(response, error) in
                let serverResponse: String = response!["description"]! as! String
                
                if (serverResponse == "Login successful") {
                    let dictionary = response!
                    self.processUserData(dictionary)
                } else if (serverResponse == "Wrong password.") {
                    DispatchQueue.main.async {
                        self.printAlert(title: "Login Information", message: "Password is incorrect.")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.printAlert(title: "Login Information", message: "User with this username does not exists.")
                    }
                }
            })
        }
        
    }
    
    private func processUserData(_ data: [String: Any]) {
        do {
            let userData: User = try unbox(dictionary: data)
            UserDefaults.standard.set(userData.id, forKey: "user_id")
            UserDefaults.standard.set(true, forKey: "status")
            Switcher.updateRootViewController()
            
        } catch {
            print("Unable to unbox")
        }
    }
    
    private func printAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}
