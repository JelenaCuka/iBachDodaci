//
//  FavoritesTableViewController.swift
//  iBach
//
//  Created by Petar Jedek on 06.12.18.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//
import UIKit
import Unbox
import AlamofireImage
import Alamofire

class FavoritesTableViewController: UITableViewController {
    
    @IBOutlet weak var tableViewFavorites: UITableView!
    
    
    var songData: [Song] = []
    
    var filteredFavorites: [Song] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        songData.removeAll()
        filteredFavorites.removeAll()
        loadData()
    }
    
    private func loadData() {
        songData.removeAll()
        //load new data
        DispatchQueue.main.async {
            HTTPRequest().sendGetRequest(urlString: "http://botticelliproject.com/air/api/favorite/findall.php?userId=\(UserDefaults.standard.integer(forKey: "user_id"))", completionHandler: {(response, error) in
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
                self.filteredFavorites = self.songData
                self.tableView.reloadData()
                
            })
        }
    
    }
    private func removeFavourite(songId: Int) {
        
        let parameters: Parameters = [
            "save": 1,
            "songId": songId,
            "userId": UserDefaults.standard.integer(forKey: "user_id")
        ]
        
        HTTPRequest().sendPostRequest2(urlString: "https://botticelliproject.com/air/api/favorite/save.php", parameters: parameters, completionHandler: {(response, error) in
            
            var serverResponse: String = ""
            serverResponse = response!["description"]! as! String
            
            if (serverResponse == "OK. Favorite song removed") {
                DispatchQueue.main.async {
                    let oldFavorites : [Song] = self.songData
                    self.songData.removeAll()
                    
                    HTTPRequest().sendGetRequest(urlString: "http://botticelliproject.com/air/api/favorite/findall.php?userId=\(UserDefaults.standard.integer(forKey: "user_id"))", completionHandler: {(response, error) in
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
                        self.filteredFavorites = self.songData
                        self.tableView.reloadData()
                        
                        //if favorites are playling and song from favorites is deleted
                        //update player
                        if (oldFavorites.count > 0 ){
                            if  oldFavorites.elementsEqual(MusicPlayer.sharedInstance.songData, by: { $0.id == $1.id }) && MusicPlayer.sharedInstance.currentSongIndex != -1  {
                                //get id of currently playing favorite
                                let currentSongId = MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].id
                                //update playing list (favorites)
                                MusicPlayer.sharedInstance.updateSongData(songsList: self.songData as [Song])
                                //update currently playing song index
                                let newCurrentSongIndex = MusicPlayer.sharedInstance.getSongIndex(song: currentSongId)
                                MusicPlayer.sharedInstance.currentSongIndex = newCurrentSongIndex
                                
                            }
                        }
                    })
                }
            }
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredFavorites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "favoriteCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FavoriteSongTableViewCell else {
            fatalError("Error")
        }
        
        if let imageURL = URL(string: self.filteredFavorites[indexPath.row].coverArtUrl) {
            let color: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4)
            
            cell.imageViewCoverArt.layer.cornerRadius = 5
            cell.imageViewCoverArt.clipsToBounds = true
            cell.imageViewCoverArt.layer.borderWidth = 0.5
            cell.imageViewCoverArt.layer.borderColor = color.cgColor
            cell.imageViewCoverArt.af_setImage(withURL: imageURL)
        }
        
        cell.labelTrackTitle.text = self.filteredFavorites[indexPath.row].title
        cell.labelAuthor.text = self.filteredFavorites[indexPath.row].author
        cell.id = self.filteredFavorites[indexPath.row].id
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .normal, title:  "Remove", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            //CONDITION 1 - delete any favorite if player never started
            //CONDITION 2 - delete song if favoriters aren't playing or if favorites are playing
            //but current song is different than song to be deleted
            
            if(MusicPlayer.sharedInstance.currentSongIndex == -1 ||
                !( self.songData.elementsEqual(MusicPlayer.sharedInstance.songData, by: { $0.id == $1.id }) &&
                    self.filteredFavorites[indexPath.row].id == MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].id) ){
                self.removeFavourite(songId: self.filteredFavorites[indexPath.row].id)
            }
            
        })
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
 
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        MusicPlayer.sharedInstance.updateSongData(songsList: songData as [Song])
        
        if(MusicPlayer.sharedInstance.playSong(song: filteredFavorites[indexPath.row].id)){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayMiniPlayer"), object: nil)
            self.searchController.searchBar.text! = ""
            self.searchController.isActive = false
        }
    }
    
}

extension FavoritesTableViewController: UISearchResultsUpdating  {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            filteredFavorites = songData
        }
        else{
            filteredFavorites = songData.filter( {$0.title.lowercased().contains(searchController.searchBar.text!.lowercased() )} )
        }
        self.tableView.reloadData()


    }
}
