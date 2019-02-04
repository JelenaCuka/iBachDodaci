//
//  Switcher.swift
//  iBach
//
//  Created by Petar Jedek on 09.11.18.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import Foundation
import UIKit

class Switcher {

    static func updateRootViewController() {
        let status = UserDefaults.standard.bool(forKey: "status")
        var rootViewController : UIViewController?
        
        print(status)
        
        if (status == true) {
            rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        }
        else {
            rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            
            //rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        }
        
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = rootViewController
        }
        
    }
    
}
