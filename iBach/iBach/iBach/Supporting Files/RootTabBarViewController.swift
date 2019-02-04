//
//  RootTabBarViewController.swift
//  iBach
//
//  Created by Petar Jadek on 15/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import UIKit

class RootTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
        
        self.tabBar.invalidateIntrinsicContentSize()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
