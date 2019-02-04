//
//  LyricsViewController.swift
//  iBach
//
//  Created by Neven Travaš on 25/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import UIKit

class LyricsViewController: UIViewController {

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        lyricsTextView.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       _showCurrentPlayingSongLyrics()
    }
    

    @IBAction func didSelectCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func _show(text: String) {
        activityIndicator.isHidden = true
        lyricsTextView.isHidden = false
        lyricsTextView.text = text
    }
    
    private func _showCurrentPlayingSongLyrics() {
        let datasourceRawValue: String = UserDefaults.standard.string(forKey: "songDataSource") ?? ""
        let defaultDatasource: DataSourceType = .musicxmatch
        let selectedDatasourceType: DataSourceType = DataSourceType(rawValue: datasourceRawValue) ?? defaultDatasource
        guard let currentSong = MusicPlayer.sharedInstance.currentSong else { return } //hendlajte logiku ak nema pjesme
        
        let datasource = DataSourceManager().currentDataSource(selectedDatasourceType: selectedDatasourceType)
        
        datasource.getLyrics(withSongTitle: currentSong.title,
                             author: currentSong.author,
                             onSuccess: { (lyrics) in self._show(text: lyrics) },
                             onFailure: {(error) in self._show(text: "Sorry, an error occured. Please try again.")})
        
    }
}
