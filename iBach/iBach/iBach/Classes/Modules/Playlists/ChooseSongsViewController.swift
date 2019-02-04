//
//  ChooseSongsViewController.swift
//  iBach
//
//  Created by Nikola on 26/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import UIKit
import Foundation
import Unbox
import Alamofire

class ChooseSongsViewController: UIViewController, ControllerDelegate {
    
    var selected: [Song] = []
    var playlistData: [Playlist] = []
    var playlist: Playlist?
    
    func enableAddButton(songs: [Song]) {
        
        selected = songs
        
        if(selected.count > 0){
            buttonAdd.isEnabled = true
        }
        else{
            buttonAdd.isEnabled = false
        }
    }
    
    var playlistName:String?
    
    @IBOutlet weak var playlistNameLabel: UILabel!
    
    @IBOutlet weak var buttonAdd: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        buttonAdd.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "veza") {
            let vc = segue.destination as! SongsTableViewController
            vc.delegate = self
        }
    }
    
    
    @IBAction func addNewPlaylist(_ sender: Any) {
        
        DispatchQueue.main.async {
            let parameters = ["user_id": UserDefaults.standard.integer(forKey: "user_id"),
                              "name" : self.playlistName!,
                              "cover_art_url" : self.selected[0].coverArtUrl,
                              "save" : 1] as [String : Any]
            
            Alamofire.request("https://botticelliproject.com/air/api/playlists/save.php", method: .post, parameters: parameters)
        }
        
        let alert = UIAlertController(title: "Playlist added", message: "Your playlist has been added to library.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
            action in
            
            DispatchQueue.main.async {
                self.loadData()
                //Switcher.updateRootViewController()
                
                let playlistScreen = (self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3])!
                self.navigationController?.popToViewController(playlistScreen, animated: true)
            }
        }))
        
        self.present(alert, animated: true)
        
        
    }
    
    private func loadData() {
        DispatchQueue.main.async {
            HTTPRequest().sendGetRequest(urlString: "https://botticelliproject.com/air/api/playlists/findall.php?userId=\(UserDefaults.standard.integer(forKey: "user_id"))", completionHandler: {(response, error) in
                if let data: NSArray = response as? NSArray {
                    for playlist in data {
                        do {
                            
                            let playlist: Playlist = try unbox(dictionary: (playlist as! NSDictionary) as! UnboxableDictionary)
                            self.playlistData.append(playlist)
                        }
                        catch {
                            print("Unable to unbox")
                        }
                    }
                }
                self.playlist = self.playlistData.last
                if(self.playlist?.name == self.playlistName){
                    DispatchQueue.main.async {
                        for song in self.selected {
                            do{
                                let parameters = ["save": 1,
                                                  "playlistId" : self.playlist?.id,
                                                  "songId" : song.id] as [String : Any]
                                
                                Alamofire.request("https://botticelliproject.com/air/api/playlistSong/save.php", method: .post, parameters: parameters)
                                //print(song.title)
                            }
                        }
                    }
                }
            })
        }
    }
}
