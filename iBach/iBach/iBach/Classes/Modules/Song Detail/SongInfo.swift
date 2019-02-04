//
//  MusicMatchSongDatasource.swift
//  iBach
//
//  Created by Neven Travaš on 15/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import Foundation
import Alamofire
import Unbox

class SongInfo: SongDetailDatasource {
    
    var apiKey: String = "283b17a8135b8122338600b0b136ec04"
    var baseURL: String = "http://ws.audioscrobbler.com/2.0/"
    
    func getLyrics(withSongTitle songTitle: String, author: String, onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error) -> Void) {
        let urlStr = "\(baseURL)/?method=track.getInfo&track=\(songTitle)&artist=\(author)&api_key=\(apiKey)&format=json&fbclid=IwAR0Dl22r0hMVCw2DM2P7iYJacTB3fzKLayR3L6qkoa17TIsbbsAwxkkThPE"
        guard
            let urlString = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlString)
            else { print("Invalid url")
                return
        }
        
        Alamofire.request(url, method:.get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
            switch response.result {
            case .success(let responseJSON):
                do {
                    
                    let json = responseJSON as? [String: Any]
                    let unboxer = try Unboxer(dictionary: json!)
                    let songInfo: String = try unboxer.unbox(keyPath: "track.wiki.content", allowInvalidElements: false)
                    onSuccess(songInfo)
                } catch {
                    onFailure(error)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

