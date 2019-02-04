//
//  similarTracks.swift
//  iBach
//
//  Created by Infinum on 29/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//


import Foundation
import Alamofire
import Unbox

class SimilarTracks: SongDetailDatasource {
    
    
    var apiKey: String = "283b17a8135b8122338600b0b136ec04"
    var baseURL: String = "http://ws.audioscrobbler.com/2.0/"
    
    func getLyrics(withSongTitle songTitle: String, author: String, onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error) -> Void) {
        let urlStr = "\(baseURL)/?method=track.getsimilar&track=\(songTitle)&artist=\(author)&api_key=\(apiKey)&format=json&fbclid=IwAR0Dl22r0hMVCw2DM2P7iYJacTB3fzKLayR3L6qkoa17TIsbbsAwxkkThPE"
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
                    var similar = "\n\n"
                    if let lyrics :[Any] = try unboxer.unbox(keyPath: "similartracks.track", allowInvalidElements: true) {
                        //var haveSimilar = false
                        for song in lyrics {
                            similar += "\n\n"
                            let unboxer2 = try Unboxer(dictionary: song as! Dictionary)
                            similar += try unboxer2.unbox(keyPath: "name", allowInvalidElements: false) + " - "
                            similar += try unboxer2.unbox(keyPath: "artist.name", allowInvalidElements: false)
                        }
                    }
                    onSuccess(similar)
                } catch {
                    onFailure(error)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

