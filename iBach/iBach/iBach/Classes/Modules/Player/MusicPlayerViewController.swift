//
//  MusicPlayerViewController.swift
//  iBach
//
//  Created by Petar Jadek on 14/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import UIKit
import AVKit
import Alamofire
import Unbox

class MusicPlayerViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var labelSongTitle: UILabel!
    @IBOutlet weak var labelSongArtist: UILabel!
    @IBOutlet weak var imageCoverArt: UIImageView!
    @IBOutlet weak var shadow: UIView!
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonFavorite: UIButton!
    
    var updater : CADisplayLink! = nil
    @IBOutlet weak var progressSongTime: UISlider!
    
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var progressVolume: UISlider!
    @IBOutlet weak var returnButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadow.layer.shadowColor = UIColor.black.cgColor
        shadow.layer.shadowOpacity = 0.8
        shadow.layer.shadowOffset = CGSize.zero
        shadow.layer.shadowRadius = 23
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayLargePlayer(notification:)), name: NSNotification.Name(rawValue: "displayMiniPlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayLargePlayer(notification:)), name: NSNotification.Name(rawValue: "displayLargePlayer"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changePlayPauseIcon(notification:)), name: NSNotification.Name(rawValue: "songIsPlaying"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changePlayPauseIcon(notification:)), name: NSNotification.Name(rawValue: "songIsPaused"), object: nil)
        
        
        progressSongTime.maximumValue = 1.0
        checkOldVolume()
        
        
        self.progressSongTime.setThumbImage(UIImage(named: "thumbImage")!, for: .normal)
        self.progressSongTime.setThumbImage(UIImage(named: "thumbImage")!, for: .highlighted)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
        self.progressSongTime.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUiColors()
    }
    
    func updateUiColors() {
        let themeRow = UserDefaults.standard.integer(forKey: "theme")
        let currentTheme = ThemeSwitcher().switchThemes(row: themeRow)
        
        labelSongTitle.textColor = currentTheme.labelColor
        labelSongArtist.textColor = currentTheme.buttonColor
        
        buttonPrevious.tintColor = currentTheme.labelColor
        buttonNext.tintColor = currentTheme.labelColor
        buttonPlay.tintColor = currentTheme.labelColor
        returnButton.tintColor = currentTheme.buttonColor
    
        
        buttonFavorite.tintColor = currentTheme.buttonColor
        
        progressVolume.tintColor = currentTheme.buttonColor
        progressSongTime.tintColor = currentTheme.buttonColor
    }
    
    override func viewDidLayoutSubviews() {
        let scrollViewBounds = scrollView.bounds
        //let containerViewBounds = contentView.bounds
        
        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = scrollViewBounds.size.height / 2.0
        scrollViewInsets.top -= contentView.bounds.size.height / 2.0
        
        scrollViewInsets.bottom  = scrollViewBounds.size.height/2.0
        scrollViewInsets.bottom -= contentView.bounds.size.height/2.0
        scrollViewInsets.bottom += 1
        
        scrollView.contentInset = scrollViewInsets
    }
    
    
    @IBAction func returnFromLargePlayer(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func changePlayPauseIcon(notification: NSNotification) {
        changePlayPauseIcon()
        updateUiColors()
    }
    
    @objc func displayLargePlayer(notification: NSNotification) {
        loadData()
        updateUiColors()
    }
    
    @IBAction func pauseSong(_ sender: Any) {
        if ( MusicPlayer.sharedInstance.playSong() ){
            NotificationCenter.default.post(name: .songIsPlaying, object: nil)
        }else if ( MusicPlayer.sharedInstance.pauseSong() ){
            NotificationCenter.default.post(name: .songIsPaused, object: nil)
        }
    }
    
    @IBAction func buttonNextClick(_ sender: Any) {
        if ( MusicPlayer.sharedInstance.nextSong() ) {
            loadData()
            NotificationCenter.default.post(name: .changedSong, object: nil)
        }
    }
    
    
    @IBAction func buttonPreviousClick(_ sender: Any) {
        if ( MusicPlayer.sharedInstance.previousSong() ) {
            NotificationCenter.default.post(name: .changedSong, object: nil)
            loadData()
        }
    }
    
    @IBAction func buttonFavoriteClick(_ sender: Any) {
        //
        setFavoriteIcon()
        updateUiColors()
    }
    func setFavoriteIcon(){
        DispatchQueue.main.async {
            
            let parameters: Parameters = [
                "save": 1,
                "songId": MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].id,
                "userId": UserDefaults.standard.integer(forKey: "user_id")
            ]
            
            HTTPRequest().sendPostRequest2(urlString: "https://botticelliproject.com/air/api/favorite/save.php", parameters: parameters, completionHandler: {(response, error) in
                var serverResponse: String = ""
                serverResponse = response!["description"]! as! String ?? ""
                
                if (serverResponse == "OK. Favorite song removed") {
                    self.buttonFavorite.setImage(UIImage(named: "Favorite"), for: .normal)
                }
                if (serverResponse == "OK. Favorite song added.") {
                    self.buttonFavorite.setImage(UIImage(named: "UnFavorite"), for: .normal)
                }
            })
        }
        
    }
    func isFavoriteIcon(){
        DispatchQueue.main.async {
            HTTPRequest().sendGetRequest(urlString: "http://botticelliproject.com/air/api/favorite/findone.php?userId=\(UserDefaults.standard.integer(forKey: "user_id"))&songId=\(MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].id)", completionHandler: {(response, error) in
                do {
                    let singleSong: Song = try unbox(dictionary: (response as! NSDictionary) as! UnboxableDictionary)
                        if (singleSong.id == MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].id ) {
                            self.buttonFavorite.setImage(UIImage(named: "UnFavorite"), for: .normal)
                            self.updateUiColors()
                        }
                }
                catch {
                    self.buttonFavorite.setImage(UIImage(named: "Favorite"), for: .normal)
                    self.updateUiColors()
                }
            })
        }
        
    }
    
    @IBAction func changeSongTime(_ sender: Any) {
        let newTime = Double (progressSongTime.value )
        MusicPlayer.sharedInstance.player?.seek(to: CMTimeMakeWithSeconds ( newTime , preferredTimescale: (MusicPlayer.sharedInstance.player?.currentItem?.currentTime().timescale)! ) )
    }
    
    @IBAction func changeVolume(_ sender: Any) {
        MusicPlayer.sharedInstance.changeVolume(newVolume: progressVolume.value)
    }
    func checkOldVolume() {
        progressVolume.value = MusicPlayer.sharedInstance.player.volume
    }
    
    func loadData() {
        self.labelSongTitle.text = MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].title
        
        if let imageURL = URL(string: MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].coverArtUrl) {
                self.imageCoverArt.layer.cornerRadius = 20
                self.imageCoverArt.clipsToBounds = true
            
                imageCoverArt.layer.shadowColor = UIColor.black.cgColor
                imageCoverArt.layer.shadowOpacity = 1
                imageCoverArt.layer.shadowOffset = CGSize.zero
                imageCoverArt.layer.shadowRadius = 50
            
                self.imageCoverArt.af_setImage(withURL: imageURL)
        }
    
        let artist: String = MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].author
        let year: String = MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].year
        
        self.labelSongArtist.text = "\(artist) - \(year)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayLargePlayer(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: MusicPlayer.sharedInstance.player?.currentItem)
        
        self.endTime.text = formatSongDuration( duration: MusicPlayer.sharedInstance.currentSongDuration() )
            progressSongTime.maximumValue = Float ( MusicPlayer.sharedInstance.currentSongDuration() )
            trackAudio()
            changePlayPauseIcon()
            checkOldVolume()
        
        isFavoriteIcon()
        
        updateUiColors()
    
    }
    
    func changePlayPauseIcon() {
        if ( MusicPlayer.sharedInstance.isPlaying() ){
            buttonPlay.setImage(UIImage(named: "Pause"), for: .normal)
            startProgressBar()
            updateUiColors()
        } else {
            buttonPlay.setImage(UIImage(named: "Play"), for: .normal)
            stopProgressBar()
            updateUiColors()
        }
        
    }
    
    func startProgressBar() {
        progressSongTime.maximumValue = Float ( MusicPlayer.sharedInstance.currentSongDuration() )
        updater = CADisplayLink(target: self, selector: #selector(trackAudio) )
        updater.preferredFramesPerSecond = 1
        updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common )
    }
    
    func stopProgressBar() {
        if updater != nil {
            updater.invalidate()
        }
    }
    
    @objc func trackAudio() {
        let currentTime = MusicPlayer.sharedInstance.currentSongTime()
        progressSongTime.value = Float ( currentTime )
        
        self.currentTime.text = formatSongDuration( duration: currentTime )
    }
    
    func formatSongDuration( duration: Int ) -> String {
        let seconds = duration % 60
        let minutes = ( duration - seconds ) / 60
        var newSeconds = "00"
        var newMinutes = "00"
        if seconds == 0 {
            newSeconds = "00"
        } else if seconds < 10 {
            newSeconds = "0\(seconds)"
        } else {
            newSeconds = "\(seconds)"
        }
        if minutes == 0 {
            newMinutes = "00"
        } else if minutes < 10 {
            newMinutes = "0\(minutes)"
        } else {
            newMinutes = "\(minutes)"
        }
        return "\(newMinutes):\(newSeconds)"
    }
    
    //change song time on tap
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.view)
        let positionOfSlider: CGPoint = progressSongTime.frame.origin
        let widthOfSlider: CGFloat = progressSongTime.frame.size.width
        
        let newTime: CGFloat = ((pointTapped.x - positionOfSlider.x) * CGFloat(progressSongTime.maximumValue) / widthOfSlider)
        
        progressSongTime.setValue(Float(newTime), animated: true)
        MusicPlayer.sharedInstance.player?.seek(to: CMTimeMakeWithSeconds ( Float64 (newTime) , preferredTimescale: (MusicPlayer.sharedInstance.player?.currentItem?.currentTime().timescale)! ) )
    }
    
    
    //@IBAction func lyricsButtonTapHandler(_ sender: Any) {
        
    //}

}

extension Notification.Name {
    static let displayLargePlayer = Notification.Name ("displayLargePlayer")//icons
    static let songIsPlaying = Notification.Name ("songIsPlaying")//icons
    static let songIsPaused = Notification.Name ("songIsPaused")//icons
    static let changedSong = Notification.Name ("changedSong")//updateInfo
}
