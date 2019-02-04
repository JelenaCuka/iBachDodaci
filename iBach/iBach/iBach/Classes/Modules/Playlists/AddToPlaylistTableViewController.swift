//
//  AddToPlaylistTableViewController.swift
//  iBach
//
//  Created by Goran Alković on 28/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

//import UIKit
import Foundation
import Unbox
import Alamofire
import AlamofireImage

class CheckableTableViewCell : UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
}

class AddToPlaylistTableViewController: UITableViewController {
    
    public func customInit(_ id: Int, _ songs: [Song]) {
        self.playlistId = id
        self.currentSongs = songs
    }
    
    var playlistId : Int = -1
    var currentSongs : [Song] = []
    
    var songData: [Song] = []
    var selectedSongs : [Song] = []
    
     let placeholder = try? Data(contentsOf: URL(string: "https://botticelliproject.com/air/musicapp/src/img/5bfef740a7f6e.mp3.jpg")!)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Add songs"
        
        self.tableView.allowsMultipleSelection = true
        
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Add", style: UIBarButtonItem.Style.done, target: self, action: #selector(addNewItems) )
        self.navigationItem.rightBarButtonItem?.isEnabled = false
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func addNewItems(){
        for song in selectedSongs {
            let params = ["save": 1, "playlistId": playlistId, "songId": song.id] as [String : Any]
            
            Alamofire.request("https://botticelliproject.com/air/api/playlistSong/save.php", method: .post, parameters: params)
        }
        
        let prevController = self.navigationController?.viewControllers[1] as! PlaylistDetailsTableViewController

        prevController.songData.removeAll()
        prevController.loadData()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        loadData()
    }

    // Custom cell image size
    func image(_ image:UIImage, withSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.automatic)
    }
    
    func loadData(){
        DispatchQueue.main.async {
            HTTPRequest().sendGetRequest(urlString: "https://botticelliproject.com/air/api/song/findall.php", completionHandler: {(response, error) in
                if let data: NSArray = response as? NSArray {
                    for song in data {
                        do {
                            
                            let singleSong: Song = try unbox(dictionary: (song as! NSDictionary) as! UnboxableDictionary)
                            if !self.currentSongs.contains(where: {$0.id == singleSong.id}){
                                self.songData.append(singleSong)
                            }
                            
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
    
    // MARK: - Table view data source


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CheckableTableViewCell(style: .subtitle, reuseIdentifier: "playlistAddSongCell")
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSongs.append(songData[indexPath.row])
        
        self.navigationItem.rightBarButtonItem?.isEnabled = selectedSongs.count > 0
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let ind = selectedSongs.index(where: {$0.id == songData[indexPath.row].id})
        selectedSongs.remove(at: ind!)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = selectedSongs.count > 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songData.count
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
