//
//  PlaylistDetailsTableViewController.swift
//  iBach
//
//  Created by Goran Alković on 26/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import Foundation
import Unbox
import Alamofire
import AlamofireImage

class PlaylistDetailsTableViewController: UITableViewController {

    var songData: [Song] = []
    
    var playlistId: Int = -1
    var playlistName: String = ""
    
    let placeholder = try? Data(contentsOf: URL(string: "https://botticelliproject.com/air/musicapp/src/img/5bfef740a7f6e.mp3.jpg")!)
    
    public func customInit(_ id: Int, _ name: String) {
        self.playlistId = id
        self.playlistName = name
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 70
        
        loadData()
        
        self.navigationItem.title = playlistName
        
        self.navigationItem.backBarButtonItem?.title = playlistName
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addToPlaylist)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.compose, target: self, action: #selector(editPlaylist)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: self, action: #selector(deletePlaylist)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(sharePlaylist))
        ]
    }
    
    @objc private func addToPlaylist() {
        let newView = AddToPlaylistTableViewController()
        newView.customInit(playlistId, songData)
        self.navigationController?.pushViewController(newView, animated: true)
    }
    
    @objc private func sharePlaylist() {
        let items = ["com.ibach://playlist?id=\(playlistId)"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @objc private func editPlaylist() {
        let alert =  UIAlertController(title: "Rename playlist", message:"Enter a new name", cancelButtonTitle: "Cancel", okButtonTitle: "Rename", validate: TextValidationRule.nonEmpty, onCompletion: commitNewName)
        self.present(alert, animated: true)
    }
    
    func commitNewName(_ result:UIAlertController.TextInputResult) {
        switch result
        {
        case .ok(let newName):
        
            DispatchQueue.main.async {
                let parameters = ["update": 1, "id" : self.playlistId, "name": newName] as [String : Any]
                
                Alamofire.request("https://botticelliproject.com/air/api/playlists/update.php", method: .post, parameters: parameters)
                
                self.navigationItem.title = newName
            }
            
        default: break
        }
    }
    
    @objc private func deletePlaylist() {
        let alert = UIAlertController(title: "Delete playlist \(self.playlistName)?", message: "This cannot be undone", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: {
            action in
            
            DispatchQueue.main.async {
                let parameters = ["delete": 1, "playlist_id" : self.playlistId]
                
                Alamofire.request("https://botticelliproject.com/air/api/playlists/delete.php", method: .post, parameters: parameters)
                
                self.navigationController?.popViewController(animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    public func loadData() {
        DispatchQueue.main.async {
            HTTPRequest().sendGetRequest(urlString: "https://botticelliproject.com/air/api/playlistSong/findall.php?playlistId=\(self.playlistId)", completionHandler: {(response, error) in
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songData.count
    }
    
    // Custom cell image size
    func image(_ image:UIImage, withSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.automatic)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "playlistSongDetail")
        
        cell.preservesSuperviewLayoutMargins = true
        cell.separatorInset = UIEdgeInsets.init(top: 0, left: 18, bottom: 0, right: 0)
        //cell.layoutMargins = UIEdgeInsets.zero
        
        cell.textLabel?.text = self.songData[indexPath.row].title
        cell.textLabel?.font = AppLabel.appearance().font
        cell.textLabel?.textColor = AppLabel.appearance().textColor
            
        cell.detailTextLabel?.text = self.songData[indexPath.row].author
        cell.detailTextLabel?.font = cell.detailTextLabel?.font.withSize(14)
        cell.detailTextLabel?.textColor = AppSubhead.appearance().textColor
        
        if URL(string: self.songData[indexPath.row].coverArtUrl) != nil {
            
            let color: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4)
        
            cell.imageView?.layer.cornerRadius = 5
            cell.imageView?.clipsToBounds = true
            cell.imageView?.layer.borderWidth = 0.5
            cell.imageView?.layer.borderColor = color.cgColor
            
            // Download cover image
            let url = URL(string: songData[indexPath.row].coverArtUrl)
            //let data = try? Data(contentsOf: url!)
        
            //cell.imageView?.image = image(UIImage(data: data!)!, withSize: CGSize(width: 50, height: 50))
           
            let filter = AspectScaledToFillSizeFilter (size: CGSize(width: 50, height: 50))
            
            let placeholderImg = image(UIImage(data: placeholder!)!, withSize: CGSize(width: 50, height: 50))
            
            //cell.imageView?.af_setImage(withURL: url!)
            cell.imageView?.af_setImage(withURL: url!, placeholderImage: placeholderImg, filter: filter )
            
        
        }
        
        return cell
    }
    
    
    // Swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Intentionally blank in order to be able to use UITableViewRowActions
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteHandler: (UITableViewRowAction, IndexPath) -> Void = { _, indexPath in
    
 
            if self.songData.count > 1 {
                
                DispatchQueue.main.async {
                let parameters = ["delete": 1, "playlistId" : self.playlistId, "songId": self.songData[indexPath.row].id]
                    if(self.songData[indexPath.row].id != MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].id){
                        
                        let oldPlaylist : [Song] = self.songData
                        Alamofire.request("https://botticelliproject.com/air/api/playlistSong/delete.php", method: .post, parameters: parameters)
                        
                        self.songData.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                            if (oldPlaylist.count > 0 ){
                                if  oldPlaylist.elementsEqual(MusicPlayer.sharedInstance.songData, by: { $0.id == $1.id }) {
                                    let currentSongId = MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].id
                                    MusicPlayer.sharedInstance.updateSongData(songsList: self.songData as [Song])
                                    let newCurrentSongIndex = MusicPlayer.sharedInstance.getSongIndex(song: currentSongId)
                                    MusicPlayer.sharedInstance.currentSongIndex = newCurrentSongIndex
                                }
                            }
                        //})
                    }
                
            }
            
    
            }
            else {
                let alert = UIAlertController(title: "Delete song?", message:"Deleting the last song will also delete the playlist", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: {
                    action in
                    
                    DispatchQueue.main.async {
                        let parameters = ["delete": 1, "playlist_id" : self.playlistId]
                        
                        Alamofire.request("https://botticelliproject.com/air/api/playlists/delete.php", method: .post, parameters: parameters)
                        
                        
                        
                        //
                        
                        //
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                
                self.present(alert, animated: true)
            }
        }
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "Remove", handler: deleteHandler)
        
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MusicPlayer.sharedInstance.updateSongData(songsList: songData as [Song])
        
        if(MusicPlayer.sharedInstance.playSong(song: songData[indexPath.row].id)){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "displayMiniPlayer"), object: nil)
        }
        
    }
 
}
