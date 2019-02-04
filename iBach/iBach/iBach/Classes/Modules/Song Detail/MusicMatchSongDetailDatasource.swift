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

class MusicMatchSongDetailsDataSource: SongDetailDatasource {

 
    var apiKey: String = "6083dead0acf13220fece4c4bef05cfb"
    var baseURL: String = "https://api.musixmatch.com/ws/1.1"
    
    func getLyrics(withSongTitle songTitle: String, author: String, onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error) -> Void) {
        let urlStr = "\(baseURL)/matcher.lyrics.get?q_track=\(songTitle)&q_artist=\(author)&apikey=\(apiKey)"
        guard
            let urlString = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlString)
        else { print("Invalid url")
             //Handle this case separatelz
            return
        }
            
        Alamofire.request(url, method:.get, parameters: nil, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
            switch response.result {
            case .success(let responseJSON):
                do {
                    let json = responseJSON as? [String: Any]
                    let unboxer = try Unboxer(dictionary: json!)
                    let lyrics: String = try unboxer.unbox(keyPath: "message.body.lyrics.lyrics_body", allowInvalidElements: false)
                    let lyricsSplitted = lyrics.components(separatedBy: "...").first ?? "No content..."
                    onSuccess(lyricsSplitted)
                } catch {
                    onFailure(error)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }

}

