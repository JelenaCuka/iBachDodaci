//
//  LargePlayerViewController.swift
//  iBach
//
//  Created by Petar Jedek on 06.12.18.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import UIKit
import AlamofireImage
import NotificationCenter
import AVFoundation
import AVKit
import MediaPlayer

class LargePlayerViewController: UIViewController {
   
    @IBOutlet weak var labelSongTitle: UILabel!
    @IBOutlet weak var imageCoverArt: UIImageView!
    @IBOutlet weak var labelArtistAlbumYear: UILabel!
    
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonPrevious: UIButton!
    
    var updater : CADisplayLink! = nil
    @IBOutlet weak var progressSongTime: UISlider!
    @IBOutlet weak var CurrentTime: UILabel!
    @IBOutlet weak var EndTime: UILabel!
    
    
    @IBOutlet weak var progressVolume: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let effect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: effect)
        blurView.frame = self.view.bounds
        self.view.addSubview(blurView)
        self.view.sendSubviewToBack(blurView)
        
        
        let screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.dismissLargePlayer(_:)))
        screenEdgeRecognizer.edges = .top
        view.addGestureRecognizer(screenEdgeRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayLargePlayer(notification:)), name: NSNotification.Name(rawValue: "displayMiniPlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayLargePlayer(notification:)), name: NSNotification.Name(rawValue: "displayLargePlayer"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(changePlayPauseIcon(notification:)), name: NSNotification.Name(rawValue: "songIsPlaying"), object: nil)//
        
        NotificationCenter.default.addObserver(self, selector: #selector(changePlayPauseIcon(notification:)), name: NSNotification.Name(rawValue: "songIsPaused"), object: nil)//
        
        progressVolume.value = 1.0
        
        progressSongTime.maximumValue = 1.0
        //progressSongTime.setThumbImage("thumbImage.png", for:.normal)
        self.progressSongTime.setThumbImage(UIImage(named: "thumbImage")!, for: .normal)
        self.progressSongTime.setThumbImage(UIImage(named: "thumbImage")!, for: .highlighted)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
        self.progressSongTime.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    
    
    @objc func dismissLargePlayer(_ sender: UIScreenEdgePanGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func displayLargePlayer(notification: NSNotification) {
        loadData()
    }
    
    @IBAction func closeLargePlayer(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

    @IBAction func lyricsButtonTapHandler(_ sender: Any) {
       
    }
    
    @objc func changePlayPauseIcon(notification: NSNotification) {
        changePlayPauseIcon()
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
        //let album: String = (notification.userInfo!["album"]! as? String)!
        let year: String = MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].year
        
        self.labelArtistAlbumYear.text = "\(artist) - \(year)"
        
        //
        NotificationCenter.default.addObserver(self, selector: #selector(displayLargePlayer(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: MusicPlayer.sharedInstance.player?.currentItem)
        
        self.EndTime.text = formatSongDuration( duration: MusicPlayer.sharedInstance.currentSongDuration() )
        
    }
    
    func changePlayPauseIcon() {
        if ( MusicPlayer.sharedInstance.isPlaying() ){
            buttonPlay.setImage(UIImage(named: "Pause"), for: .normal)
            startProgressBar()
        } else {
            buttonPlay.setImage(UIImage(named: "Play"), for: .normal)
            stopProgressBar()
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
        
        self.CurrentTime.text = formatSongDuration( duration: currentTime )
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
    
    @IBAction func changeVolume(_ sender: Any) {
        let newVolume = progressVolume.value
        MusicPlayer.sharedInstance.player.volume = newVolume
    }
    
    //change song time on slide
    @IBAction func changeSongTime(_ sender: Any) {
        let newTime = Double (progressSongTime.value )
        MusicPlayer.sharedInstance.player?.seek(to: CMTimeMakeWithSeconds ( newTime , preferredTimescale: (MusicPlayer.sharedInstance.player?.currentItem?.currentTime().timescale)! ) )
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
    
}

extension Notification.Name {
    static let songIsPlaying = Notification.Name ("songIsPlaying")//icons
    static let songIsPaused = Notification.Name ("songIsPaused")//icons
    static let changedSong = Notification.Name ("changedSong")//updateInfo
}
