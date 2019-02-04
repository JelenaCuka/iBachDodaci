//
//  RegistraionViewController.swift
//  iBach
//
//  Created by Petar Jedek on 25.11.18.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import UIKit
import Alamofire

class RegistrationTableViewController: UITableViewController {
    
    @IBOutlet var textFieldUsername: UITextField!
    @IBOutlet var textFieldEmail: UITextField!
    @IBOutlet var textFieldFirstName: UITextField!
    @IBOutlet var textFieldLastName: UITextField!
    @IBOutlet var textFieldPassword: UITextField!
    @IBOutlet var textFieldRepeatPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func registerUser(_ sender: Any) {
        
        if (!self.checkIfSpecificDataIsNotEmpty()) {
            DispatchQueue.main.async {
                self.printAlert(title: "Missing Information", message: "You need to enter username and passwords to register.")
            }
        } else {
            if (!self.checkPasswords(password: textFieldPassword.text!, repeatPassword: textFieldRepeatPassword.text!)) {
                DispatchQueue.main.async {
                    self.printAlert(title: "Warning", message: "Passwords do not match.")
                }
            } else {
                
                let parameters: Parameters = [
                    "username": textFieldUsername.text!,
                    "password": textFieldPassword.text!.hash,
                    "first_name": textFieldFirstName.text!,
                    "last_name": textFieldLastName.text!,
                    "email": textFieldEmail.text!
                ]
                
                HTTPRequest().sendPostRequest(urlString: "https://botticelliproject.com/air/api/user/save.php", parameters: parameters, completionHandler: {(response, error) in

                    let serverResponse: String = response!["description"]! as! String
                    
                    if (serverResponse == "User successfully created.") {
                        Switcher.updateRootViewController()
                    } else if (serverResponse == "That username is already taken.") {
                        DispatchQueue.main.async {
                            self.printAlert(title: "Registraton Failed", message: "Username \(self.textFieldUsername.text!) is already taken.")
                        }
                    }
                    
                })
                
            }
        }
        
    }
    
    private func checkIfSpecificDataIsNotEmpty() -> Bool {
        if (textFieldUsername.text!.isEmpty || textFieldPassword.text!.isEmpty || textFieldRepeatPassword.text!.isEmpty) {
            return false
        }
        return true
    }
    
    private func checkPasswords(password: String, repeatPassword: String) -> Bool {
        if (password == repeatPassword) {
            return true
        }
        return false
    }
    
    private func printAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    
}
