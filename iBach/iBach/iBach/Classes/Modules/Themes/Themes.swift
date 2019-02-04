//
//  Themes.swift
//  iBach
//
//  Created by Neven Travas on 01/12/2018.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import UIKit

protocol Theme {
    var tint: UIColor { get }
    
    var backgroundColor: UIColor {get}
    var separatorColor: UIColor {get}
    var selectionColor: UIColor {get}
    
    var specialBackgroundColor: UIColor {get}
    
    var headerColor: UIColor {get}
    
    var labelColor: UIColor {get}
    var secondaryLabelColor: UIColor {get}
    var subtleLabelColor: UIColor {get}
    
    var barStyle: UIBarStyle {get}
    var textFieldColor: UIColor {get}
    var buttonColor: UIColor {get}
    var textView: UIColor {get}
    var miniPlayerColor: UIColor {get}
    var playlistLableColor: UIColor {get}
    
    var statusBarTheme: UIStatusBarStyle {get}
    
    var buttonDangerColor : UIColor {get}
    
    func apply(for application: UIApplication)
    
}

extension Theme {
    
    func apply(for application: UIApplication) {
        application.keyWindow?.tintColor = tint
        
        UITabBar.appearance().with {
            $0.barStyle = barStyle
            $0.tintColor = tint
            $0.barTintColor = headerColor.withAlphaComponent(0.3)
        }
        
        UINavigationBar.appearance().with {
            $0.barStyle = barStyle
            $0.tintColor = tint
            $0.barTintColor = headerColor
            $0.backgroundColor = .clear
            $0.titleTextAttributes = [
                .foregroundColor: labelColor
            ]
            $0.largeTitleTextAttributes = [
                .foregroundColor: labelColor
            ]
        }
        
        UISearchBar.appearance().with {
            $0.tintColor = tint
        }
        
        UILabel.appearance().textColor = labelColor
        UITextField.appearance().textColor = textFieldColor
        
        
        UITableView.appearance().with {
            $0.backgroundColor = backgroundColor
            $0.separatorColor = separatorColor
        }
        
        UITableViewCell.appearance().with {
            $0.backgroundColor = .clear
            $0.selectionColor = selectionColor
        }
        
        UIView.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
            .backgroundColor = specialBackgroundColor
    
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self, UITableViewCell.self])
            .textColor = labelColor
        
        UITextView.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self, UITableViewCell.self])
            .textColor = labelColor
        
        AppInputTableCell.appearance().with {
            $0.backgroundColor = backgroundColor
        }
        
        AppTextView.appearance().textColor = textView
        AppLabel.appearance().textColor = labelColor
        AppSubhead.appearance().textColor =  secondaryLabelColor
        //AppFootnote.appearance().textColor = subtleLabelColor
        
        AppButton.appearance().with {
            $0.setTitleColor(buttonColor, for: .normal)
        }
        
        AppDangerButton.appearance().with {
            $0.tintColor = buttonDangerColor
        }
  
        AppView.appearance().backgroundColor = backgroundColor
        
        AppSeparator.appearance().with {
            $0.backgroundColor = separatorColor
            $0.alpha = 0.5
        }
        
        AppStackView.appearance().backgroundColor = backgroundColor
        AppMiniPlayer.appearance().backgroundColor = miniPlayerColor
        AppPlaylistLable.appearance().textColor = playlistLableColor
        
        AppView.appearance(whenContainedInInstancesOf: [AppView.self]).with {
            $0.backgroundColor = specialBackgroundColor
            $0.cornerRadius = 10
        }
        
        
        // Ensure existing views render with new theme
        // https://developer.apple.com/documentation/uikit/uiappearance
        application.windows.reload()
    }
}

// Boja iz hex koda
extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
