//
//  MiniPlayerViewController.swift
//  iBach
//
//  Created by Petar Jadek on 15/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import UIKit
import Foundation
import NotificationCenter
import AVFoundation

class MiniPlayerViewController: UIViewController {

    
    @IBOutlet var miniPlayerView: UIView!
    @IBOutlet weak var labelSongTitle: UILabel!
    @IBOutlet weak var imageCoverArt: UIImageView!
    @IBOutlet weak var labelAuthor: UILabel!
    @IBOutlet weak var styledView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MusicPlayer.sharedInstance.setSession()
        UIApplication.shared.beginReceivingRemoteControlEvents()//bg playing controls
        becomeFirstResponder()

        NotificationCenter.default.addObserver(self, selector: #selector(displayMiniPlayer(notification:)), name: NSNotification.Name(rawValue: "displayMiniPlayer"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMiniPlayerData(notification:)), name: NSNotification.Name(rawValue: "changedSong"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil )
        
        
        
    }
    
    @objc func displayMiniPlayer(notification: NSNotification) {
        self.miniPlayerView.isHidden = false
        
        reloadMiniPlayerData()
        let miniPlayerTap = UITapGestureRecognizer(target: self, action: #selector(self.openLargePlayer(_:) ))
        
        self.miniPlayerView.addGestureRecognizer(miniPlayerTap)
        self.miniPlayerView.isUserInteractionEnabled = true
        
        self.styledView.layer.shadowColor = UIColor.black.cgColor
        self.styledView.layer.shadowColor = UIColor.black.cgColor
        self.styledView.layer.shadowOpacity = 0.8
        self.styledView.layer.shadowOffset = CGSize.zero
        self.styledView.layer.shadowRadius = 23
        self.styledView.layer.masksToBounds = false
        self.styledView.layer.cornerRadius = 4.0
        
        //setPlayingIcons()
    }
    
    func reloadMiniPlayerData(){
        self.labelSongTitle.text = MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].title
        self.labelAuthor.text = MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].author
        
        if let imageURL = URL(string: MusicPlayer.sharedInstance.songData[MusicPlayer.sharedInstance.currentSongIndex].coverArtUrl ) {
            let color: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.4)
            
            self.imageCoverArt.layer.cornerRadius = 3
            self.imageCoverArt.clipsToBounds = true
            self.imageCoverArt.layer.borderWidth = 0.5
            self.imageCoverArt.layer.borderColor = color.cgColor
            self.imageCoverArt.af_setImage(withURL: imageURL)
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMiniPlayerData(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: MusicPlayer.sharedInstance.player?.currentItem)
    }
    
    @objc func reloadMiniPlayerData(notification: NSNotification) {
        reloadMiniPlayerData()
    }
    
    @objc func openLargePlayer(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "LargePlayer", bundle: nil)
        let playerVC = storyboard.instantiateViewController(withIdentifier: "Player") as! MusicPlayerViewController
        
        self.present(playerVC, animated: true, completion: nil)

        playerVC.loadData();
        
    }
    override var canBecomeFirstResponder: Bool {return true}
    @objc func handleInterruption(notification: NSNotification){
        MusicPlayer.sharedInstance.pauseSong()
        let interruptionTypeAsObject = notification.userInfo![AVAudioSessionInterruptionTypeKey] as! NSNumber
        let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeAsObject.uintValue)
        if let type = interruptionType {
            if type == .ended {
                MusicPlayer.sharedInstance.playSong()
            }
        }
    }
        //handling bg playing
    override func remoteControlReceived(with event: UIEvent?) {
        if event!.type == UIEvent.EventType.remoteControl{
            if event!.subtype == UIEvent.EventSubtype.remoteControlPause {
                MusicPlayer.sharedInstance.pauseSong()
            }else if event!.subtype == UIEvent.EventSubtype.remoteControlPlay {
                MusicPlayer.sharedInstance.playSong()
            }else if event!.subtype == UIEvent.EventSubtype.remoteControlNextTrack {
                MusicPlayer.sharedInstance.nextSong()
            }else if event!.subtype == UIEvent.EventSubtype.remoteControlPreviousTrack {
                MusicPlayer.sharedInstance.previousSong()
            }
        }
    }

}
