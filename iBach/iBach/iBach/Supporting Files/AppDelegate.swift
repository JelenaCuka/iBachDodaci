//
//  AppDelegate.swift
//  iBach
//
//  Created by Petar Jedek on 05.11.18.
//  Copyright © 2018 Petar Jadek. All rights reserved.
//

import UIKit
import Foundation
import Unbox
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Switcher.updateRootViewController()
        
        let themeRow = UserDefaults.standard.integer(forKey: "theme")
        let theme = ThemeSwitcher().switchThemes(row:themeRow)
        theme.apply(for: application)
        
        return true
    }
    
    // Handle App URL
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        // Decompose URL
        let firstIndexOf = url.absoluteString.firstIndex(of: "?")
        let index = url.absoluteString.index(firstIndexOf!, offsetBy: 4)
        let id = Int(url.absoluteString[index...])
        
        // Show alert
        let alert = UIAlertController(title: "Load playlist?", message: "You can change the name later", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Import", style: UIAlertAction.Style.default, handler: {
            action in self.importPlaylist(id!)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        window?.rootViewController?.present(alert, animated: true)
        
        return true
    }
    
    func importPlaylist(_ id:Int) {
        DispatchQueue.main.async {
            var allSongs : [Song] = []
            
            // Get all songs from playlist
            HTTPRequest().sendGetRequest(urlString: "https://botticelliproject.com/air/api/playlistSong/findall.php?playlistId=\(id)", completionHandler: {(response, error) in
                if let data: NSArray = response as? NSArray {
                    for song in data {
                        do {
                            let singleSong: Song = try unbox(dictionary: (song as! NSDictionary) as! UnboxableDictionary)
                            allSongs.append(singleSong)
                            
                        }
                        catch {
                            print("Unable to unbox")
                        }
                    }
                    
                    Alamofire.request("https://botticelliproject.com/air/api/playlists/findone.php?id=\(id)", method: .get).responseString {response in
                        let responseString1 = String(data: response.data!, encoding: .utf8)
                        
                        let explodedString1 = responseString1?.components(separatedBy: ",")
                        let explodedName = explodedString1![1]
                        let indx1 = explodedName.lastIndex(of: ":")!
                        let shiftedIndex1 = explodedName.index(indx1, offsetBy: 1)
                        let currentPlaylistName = explodedName[shiftedIndex1...].replacingOccurrences(of: "\"", with: "")
                        
                        let explodedCoverUrl = explodedString1![5]
                        let indx2 = explodedCoverUrl.firstIndex(of: ":")!
                        let shiftedIndex2 = explodedCoverUrl.index(indx2, offsetBy: 1)
                        let currentPlaylistCoverUrl = explodedCoverUrl[shiftedIndex2...].replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\\/", with: "/")
                        
                        print(currentPlaylistCoverUrl)
                        
                        // Make a playlist
                        
                        let userId = UserDefaults.standard.integer(forKey: "user_id")
                        
                        let parameters = ["save": 1, "name": "\(currentPlaylistName) - copy", "user_id": userId, "cover_art_url": currentPlaylistCoverUrl] as [String : Any]
                        
                        Alamofire.request("https://botticelliproject.com/air/api/playlists/save.php", method: .post, parameters: parameters).responseString {
                            response in
                            let responseString = String(data: response.data!, encoding: .utf8)
                            
                            let explodedString = responseString?.components(separatedBy: ",")
                            let explodedId = explodedString![2]
                            let indx = explodedId.lastIndex(of: ":")!
                            let shiftedIndex = explodedId.index(indx, offsetBy: 1)
                            let newPlaylistId = explodedId[shiftedIndex...]
                            
                            // Put songs in
                            for song in allSongs {
                                
                                let params = ["save": 1, "playlistId": newPlaylistId, "songId": song.id] as [String : Any]
                                
                                Alamofire.request("https://botticelliproject.com/air/api/playlistSong/save.php", method: .post, parameters: params)
                            }
                            
                        }
                   
                    }
                    
                 
                }
            })
            
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

