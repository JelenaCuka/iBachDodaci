//
//  ThemeSwitcher.swift
//  iBach
//
//  Created by Neven Travaš on 25/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import Foundation

class ThemeSwitcher {
    
    func switchThemes(row: Int)->(Theme) {
        
        let theme: Theme
        switch row {
        case 1: theme = DarkTheme()
        case 2: theme = BlueTheme()
        default: theme = LightTheme()
        }
    return theme
    }
}
