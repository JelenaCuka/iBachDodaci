//
//  File.swift
//  iBach
//
//  Created by Petar Jedek on 07.12.18.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import Unbox

class Playlist: Unboxable {
    var id: Int
    var name: String
    var userId: Int
    var modifiedAt: String
    var deletedAt: String?
    var coverArtUrl: String?
    
    required init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
        self.userId = try unboxer.unbox(key: "user_id")
        self.modifiedAt = try unboxer.unbox(key: "modified_at")
        self.deletedAt = unboxer.unbox(key: "deleted_at")
        self.coverArtUrl = unboxer.unbox(key: "cover_art_url")
    }
}
