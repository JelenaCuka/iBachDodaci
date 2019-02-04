//
//  SongsTableViewController.swift
//  iBach
//
//  Created by Nikola on 27/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import Foundation
import Unbox
import Alamofire
import AlamofireImage

protocol ControllerDelegate {
    func enableAddButton(songs: [Song])
}

class SongsTableViewController: UITableViewController {
    
    var songData: [Song] = []
    var selectedSongs: [Song] = []
    
    var delegate: ControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTracks()
        
        self.tableView.allowsMultipleSelection = true
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
                self.tableView.reloadData()
            })
        }
    }
}

extension SongsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? SongsTableViewCell else {
            fatalError("Error")
        }

        cell.labelAuthor.text = self.songData[indexPath.row].author
        cell.labelTrackTitle.text = self.songData[indexPath.row].title
        
        
        if URL(string: self.songData[indexPath.row].coverArtUrl) != nil {
            let color: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4)
            
            cell.imageViewCoverArt.layer.cornerRadius = 5
            cell.imageViewCoverArt.clipsToBounds = true
            cell.imageViewCoverArt.layer.borderWidth = 0.5
            cell.imageViewCoverArt.layer.borderColor = color.cgColor
            
            // Download cover image
            let url = URL(string: songData[indexPath.row].coverArtUrl)
            cell.imageViewCoverArt.af_setImage(withURL: url!)
        }
        
        return cell
    }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? SongsTableViewCell else {
            fatalError("Error")
        }
        
        if(selectedSongs.contains(where: {$0.id == self.songData[indexPath.row].id})){
            selectedSongs.removeAll(where: {$0.id == self.songData[indexPath.row].id})
            
            cell.labelTrackTitle.textColor = UIColor.black
        }
        else{
            self.selectedSongs.append(self.songData[indexPath.row])
            /*
            cell.labelTrackTitle.textColor = UIColor(red: 88/256, green: 86/256, blue: 214/256, alpha: 1.0)
            cell.backgroundColor = UIColor(red: 88/256, green: 86/256, blue: 214/256, alpha: 1.0)
            cell.labelAuthor.textColor = UIColor(red: 88/256, green: 86/256, blue: 214/256, alpha: 1.0)
            */
 }
        delegate?.enableAddButton(songs: selectedSongs)
    }
 */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSongs.append(songData[indexPath.row])
        
        delegate?.enableAddButton(songs: selectedSongs)
        //self.navigationItem.rightBarButtonItem?.isEnabled = selectedSongs.count > 0
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let ind = selectedSongs.index(where: {$0.id == songData[indexPath.row].id})
        selectedSongs.remove(at: ind!)
        
        delegate?.enableAddButton(songs: selectedSongs)
        //self.navigationItem.rightBarButtonItem?.isEnabled = selectedSongs.count > 0
    }
}
