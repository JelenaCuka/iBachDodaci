//
//  LightTheme.swift
//  iBach
//
//  Created by Neven Travas on 01/12/2018.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import UIKit

struct LightTheme: Theme {
    let tint: UIColor = UIColor(red: 83/255, green: 47/255, blue: 189/255, alpha: 1)
    
    let backgroundColor: UIColor = UIColor(hexString: "#ffffff")//.white
    let separatorColor: UIColor = .lightGray
    let selectionColor: UIColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
    
    let headerColor: UIColor = UIColor(hexString: "#ffffff")
    
    let specialBackgroundColor: UIColor = UIColor(hexString: "#f8f8f8")
    
    let labelColor: UIColor = .black
    let secondaryLabelColor: UIColor = .darkGray
    let subtleLabelColor: UIColor = .lightGray
    let textFieldColor: UIColor = .darkGray
    let buttonColor: UIColor = UIColor(red: 83/255, green: 47/255, blue: 189/255, alpha: 1)
    let textView: UIColor = .black
    let miniPlayerColor: UIColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    let playlistLableColor: UIColor = .black
    
    let statusBarTheme: UIStatusBarStyle = UIStatusBarStyle.default
    
    let buttonDangerColor: UIColor = UIColor(hexString: "#ff3b30")
    
    let barStyle: UIBarStyle = .default
}

