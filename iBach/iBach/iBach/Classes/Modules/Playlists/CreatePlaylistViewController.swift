//
//  CreatePlaylistViewController.swift
//  iBach
//
//  Created by Nikola on 26/01/2019.
//  Copyright © 2019 Petar Jedek. All rights reserved.
//

import UIKit

class CreatePlaylistViewController: UIViewController {

    @IBAction func textfieldPlaylistNameValueChangedEvent(_ sender: Any) {
        if(texfieldPlaylistName.text!.count > 0){
            nextButton.isEnabled = true
        }
        else{
            nextButton.isEnabled = false
        }
    }
    
    @IBOutlet weak var texfieldPlaylistName: UITextField!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nextButton.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let receiverVC = segue.destination as! ChooseSongsViewController
        receiverVC.playlistName = texfieldPlaylistName.text
    }

    
    
}
