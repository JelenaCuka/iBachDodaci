//
//  RootView.swift
//  iBach
//
//  Created by Petar Jadek on 15/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import UIKit
import Foundation

class RootViewController: UIViewController  {
    
   
    // Set statusbar theme globally
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let themeRow = UserDefaults.standard.integer(forKey: "theme")
        let theme = ThemeSwitcher().switchThemes(row:themeRow)
        return theme.statusBarTheme
    }
 
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bottomConstraint.constant = self.tabBarController?.view.frame.height ?? 64.0
        self.view.layoutIfNeeded()
    }
    
}
