//
//  PlaylistSong.swift
//  iBach
//
//  Created by Goran Alković on 26/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import Unbox

class PlaylistSong: Unboxable {
    var playlistId: Int
    var songId: Int
    var modifiedAt: String
    var deletedAt: String?
    
    required init(unboxer: Unboxer) throws {
        self.playlistId = try unboxer.unbox(key: "playlist_id")
        self.songId = try unboxer.unbox(key: "song_id")
        self.modifiedAt = try unboxer.unbox(key: "modified_at")
        self.deletedAt = unboxer.unbox(key: "deleted_at")
    }
}
