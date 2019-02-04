//
//  User.swift
//  iBach
//
//  Created by Petar Jedek on 23.11.18.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import Unbox

class User: Unboxable {
    let id: Int
    let firstName: String?
    let lastName: String?
    let email: String?
    let modifiedAt: String
    let username: String
    let password: String
    
    required init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.firstName = unboxer.unbox(key: "first_name")
        self.lastName = unboxer.unbox(key: "last_name")
        self.email = unboxer.unbox(key: "email")
        self.modifiedAt = try unboxer.unbox(key: "modified_at")
        self.username = try unboxer.unbox(key: "username")
        self.password = try unboxer.unbox(key: "password")
    }
    
}
