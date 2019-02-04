//
//  With.swift
//  iBach
//
//  Created by Neven Travas on 01/12/2018.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import Foundation

public protocol With {}

public extension With where Self: Any {
    
    /// Makes it available to set properties with closures just after initializing.
    ///
    ///     let label = UILabel().with { (label: UILabel) in 
    ///       $0.textAlignment = .center
    ///       $0.textColor = UIColor.black
    ///       $0.text = "Hello, World!"
    ///     }
    @discardableResult
    func with(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: With {}
