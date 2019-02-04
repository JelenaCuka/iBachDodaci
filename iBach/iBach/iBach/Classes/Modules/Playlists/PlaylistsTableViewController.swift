//
//  PlaylistsTableViewController.swift
//  iBach
//
//  Created by Petar Jedek on 07.12.18.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import UIKit
import Unbox

class PlaylistsTableViewController: UITableViewController {
    
    var playlistData: [Playlist] = []
    var filteredPlaylist: [Playlist] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        //loadData()
        
        self.navigationItem.title = "Playlists"
        
        // It doesn't change properly sometimes, hardcoded it is
        let backItem = UIBarButtonItem()
        backItem.title = "Playlists"
        self.navigationItem.backBarButtonItem = backItem
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        playlistData.removeAll()
        filteredPlaylist.removeAll()
        loadData()
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
                self.filteredPlaylist = self.playlistData
                self.tableView.reloadData()
            })
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredPlaylist.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "playlistCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PlaylistsTableViewCell else {
            fatalError("Error")
        }
        
        if let imageURL = URL(string: self.filteredPlaylist[indexPath.row].coverArtUrl ?? "https://botticelliproject.com/air/musicapp/src/img/5bfef740a7f6e.mp3.jpg") {
            let color: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4)
            
            cell.imageViewCoverArt.layer.cornerRadius = 10
            cell.imageViewCoverArt.clipsToBounds = true
            cell.imageViewCoverArt.layer.borderWidth = 0.5
            cell.imageViewCoverArt.layer.borderColor = color.cgColor
            
            cell.imageViewCoverArt.af_setImage(withURL: imageURL)
            
            let blur = UIBlurEffect(style: .light)
            let blurView = UIVisualEffectView(effect: blur)
            blurView.frame = cell.imageViewCoverArt.bounds
            
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blur)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            
            vibrancyView.frame = blurView.contentView.bounds
            vibrancyView.contentView.addSubview(cell.imageViewLogo)
            cell.imageViewLogo.center = vibrancyView.center
            blurView.contentView.addSubview(vibrancyView)
            
            cell.imageViewCoverArt.addSubview(blurView)
        }
        
        cell.labelName.text = self.filteredPlaylist[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("Tapped on \(self.playlistData[indexPath.row].name)")
        
        let newView = PlaylistDetailsTableViewController()
        newView.customInit(self.filteredPlaylist[indexPath.row].id, self.filteredPlaylist[indexPath.row].name)
        self.navigationController?.pushViewController(newView, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
        /*let playerItem = AVPlayerItem(url: URL(string: self.songData[indexPath.row].fileUrl)!)
         player = AVPlayer(playerItem: playerItem)
         
         do {
         try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
         try AVAudioSession.sharedInstance().setActive(true)
         } catch {
         print(error)
         }
         
         player.play() */
        
        //player.playMusicFromUrl(url: URL(string: self.songData[indexPath.row].fileUrl)!)
        
        
        /*let songInfo = ["title": self.songData[indexPath.row].title,
         "author": self.songData[indexPath.row].author,
         "cover_art": self.songData[indexPath.row].coverArtUrl,
         "year": self.songData[indexPath.row].year,
         "id": self.songData[indexPath.row].id,
         /*"album": self.songData[indexPath.row].album*/] as [String : Any] */
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayMiniPlayer"), object: nil, userInfo: songInfo)
        
        //let songsToPlay = ["id": self.songData[indexPath.row].id, "others": songData] as [String: Any]
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sendSongList"), object: nil, userInfo: songsToPlay)
    }
    
}

extension PlaylistsTableViewController: UISearchResultsUpdating  {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        //filterContentForSearchText(searchController.searchBar.text!)
        if searchController.searchBar.text! == "" {
            filteredPlaylist = playlistData
        }
        else{
            filteredPlaylist = playlistData.filter( {$0.name.lowercased().contains(searchController.searchBar.text!.lowercased() )} )
        }
        self.tableView.reloadData()
    }
}
