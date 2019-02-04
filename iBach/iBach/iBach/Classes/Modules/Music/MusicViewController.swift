//
//  MusicViewController.swift
//  iBach
//
//  Created by Petar Jedek on 03.12.18.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import NotificationCenter
import UIKit
import Unbox
import AlamofireImage
import AVKit
import AVFoundation

class MusicTableViewController: UITableViewController {
   
    
    var songData: [Song] = []
    
    var filteredSongs: [Song] = []
    let searchController = UISearchController(searchResultsController: nil)

    
    var buttonPlay: UIBarButtonItem?
    var buttonShuffle: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        
        setPlayingIcons()
        loadTracks()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(changePlayPauseIcon(notification:)), name: NSNotification.Name(rawValue: "songIsPlaying"), object: nil)//
        
        NotificationCenter.default.addObserver(self, selector: #selector(changePlayPauseIcon(notification:)), name: NSNotification.Name(rawValue: "songIsPaused"), object: nil)//
        
    }
    
    @objc func playSongClick(_ sender: Any){
        playpause()
    }
    
    @objc func changePlayPauseIcon(notification: NSNotification) {
        setPlayingIcons()
    }
    
    @objc func shuffleClick(_ sender: Any){
        MusicPlayer.sharedInstance.shuffleOnOff()
    }
    
    func playpause() {
        if (!MusicPlayer.sharedInstance.playSong()) {
            MusicPlayer.sharedInstance.pauseSong()
        }
    }
    
    func setPlayingIcons() {
        if(MusicPlayer.sharedInstance.isPlaying() ){
            self.buttonPlay = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.pause, target: self, action: #selector(playSongClick))
        }else{
            self.buttonPlay = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play, target: self, action: #selector(playSongClick ))
        }
        self.buttonShuffle = UIBarButtonItem(image: UIImage(named: "Shuffle Navigation Icon"), style: .plain, target: self, action: #selector(shuffleClick))
        if let addButtonPlay = buttonPlay,let addButtonShuffle = buttonShuffle {
            navigationItem.rightBarButtonItems = [addButtonPlay , addButtonShuffle]
        }
    }
    
    private func loadTracks() {
        DispatchQueue.main.async {
            HTTPRequest().sendGetRequest(urlString: "https://botticelliproject.com/air/api/song/findall.php", completionHandler: {(response, error) in
                if let data: NSArray = response as? NSArray {
                    for song in data {
                        do {
                            let singleSong: Song = try unbox(dictionary: (song as! NSDictionary) as! UnboxableDictionary)
                            self.songData.append(singleSong)
                            
                        }
                        catch {
                            print("Unable to unbox")
                        }
                    }
                }
                self.filteredSongs = self.songData
                self.tableView.reloadData()
            })
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredSongs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "trackCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TrackTableViewCell else {
            fatalError("Error")
        }
        
        if let imageURL = URL(string: self.filteredSongs[indexPath.row].coverArtUrl) {
            let color: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4)
            
            cell.imageViewCoverArt.layer.cornerRadius = 5
            cell.imageViewCoverArt.clipsToBounds = true
            cell.imageViewCoverArt.layer.borderWidth = 0.5
            cell.imageViewCoverArt.layer.borderColor = color.cgColor
            cell.imageViewCoverArt.af_setImage(withURL: imageURL)
        }
        
        cell.labelTrackTitle.text = self.filteredSongs[indexPath.row].title
        cell.labelAuthor.text = self.filteredSongs[indexPath.row].author
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MusicPlayer.sharedInstance.updateSongData(songsList: songData as [Song])
        
        if(MusicPlayer.sharedInstance.playSong(song: filteredSongs[indexPath.row].id)){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayMiniPlayer"), object: nil)
            self.searchController.searchBar.text! = ""
            self.searchController.isActive = false
        }
    }
    
}

extension MusicTableViewController: UISearchResultsUpdating  {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        //filterContentForSearchText(searchController.searchBar.text!)
        if searchController.searchBar.text! == "" {
            filteredSongs = songData
        }
        else{
            filteredSongs = songData.filter( {$0.title.lowercased().contains(searchController.searchBar.text!.lowercased() )} )
        }
        self.tableView.reloadData()
    }
}
