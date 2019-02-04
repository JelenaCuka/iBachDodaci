//
//  SongDetail.swift
//  iBach
//
//  Created by Neven Travaš on 14/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import Foundation

protocol SongDetailDatasource {
    
    var apiKey: String { get }
    var baseURL: String { get }
    
    func getLyrics(withSongTitle songTitle: String, author: String, onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error) -> Void)
}
