//
//  DarkTheme.swift
//  iBach
//
//  Created by Neven Travas on 01/12/2018.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import UIKit

struct DarkTheme: Theme {
    
    let tint: UIColor = UIColor(hexString: "#7e57c2")
    let backgroundColor: UIColor = UIColor(hexString: "#000000")
    let separatorColor: UIColor = .darkGray
    let selectionColor: UIColor = .init(red: 38/255, green: 38/255, blue: 40/255, alpha: 1)
    
    let headerColor: UIColor = UIColor(hexString: "#000000")
    
    let specialBackgroundColor: UIColor = UIColor(hexString: "#111111")
    
    let labelColor: UIColor = .white
    let textFieldColor: UIColor = .lightGray
    let secondaryLabelColor: UIColor = .lightGray
    let subtleLabelColor: UIColor = .lightGray
    let buttonColor: UIColor = UIColor(hexString: "#7e57c2")
    let textView: UIColor = .white
    let miniPlayerColor: UIColor = .darkGray
    let playlistLableColor: UIColor = .white
    
    let barStyle: UIBarStyle = .black
    
    let buttonDangerColor: UIColor = UIColor(hexString: "#ff3b30")
    
    let statusBarTheme: UIStatusBarStyle = UIStatusBarStyle.lightContent
    
    
}
