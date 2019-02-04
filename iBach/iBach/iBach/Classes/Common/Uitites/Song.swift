//
//  Song.swift
//  iBach
//
//  Created by Petar Jedek on 01.12.18.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import Unbox

class Song: Unboxable {
    var id: Int
    var title: String
    var author: String
    var year: String
    var fileUrl: String
    var coverArtUrl: String
    
    func fixFormattingIssues(_ input: String) -> String {
        return input.replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&#923;", with: "Λ").replacingOccurrences(of: "&#246;", with: "ö")
    }
    
    required init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.title = try unboxer.unbox(key: "title")
        self.author = try unboxer.unbox(key: "author")
        self.year = try unboxer.unbox(key: "year")
        self.fileUrl = try unboxer.unbox(key: "file_url")
        self.coverArtUrl = try unboxer.unbox(key: "cover_art_url")
        
        self.title = fixFormattingIssues(self.title)
        self.author = fixFormattingIssues(self.author)
    }
}
