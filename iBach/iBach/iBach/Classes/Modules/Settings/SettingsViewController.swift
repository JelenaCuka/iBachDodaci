//
//  SettingsViewController.swift
//  iBach
//
//  Created by Neven Travas on 01/12/2018.
//  Copyright © 2018 Petar Jedek. All rights reserved.
//

import UIKit

enum DataSourceType: String {
    case musicxmatch = "Musicxmatch"
    case songLyrics = "songLyrics" // TODO: NAĐI NEKI DRUGI SOURCE ZA LYRICSE
    case myLyrics = "myLyrics"
    case songInfo = "songInfo"
    case similarTracks = "similarTracks"
}

enum AvailableThemes: String{
    case lightTheme = "Light Theme"
    case darkTheme = "Dark Theme"
    case blueTheme = "Blue Theme"
}

class SettingsViewController: UITableViewController, UITextFieldDelegate{
    
    let themePickerData: [AvailableThemes] = [.lightTheme, .darkTheme, .blueTheme]
    let songDetailData: [DataSourceType] = [.musicxmatch, .songLyrics, .myLyrics,.songInfo,.similarTracks]
    
    @IBOutlet weak var themeTextField: UITextField!
    @IBOutlet weak var songDetailTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let themeRow = UserDefaults.standard.integer(forKey: "theme")
        let currentTheme = ThemeSwitcher().switchThemes(row: themeRow)
        self.tableView.backgroundColor = currentTheme.specialBackgroundColor
        
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let themePicker = UIPickerView()
        let songDetailPicker = UIPickerView()
        themeTextField.inputView = themePicker
        songDetailTextField.inputView = songDetailPicker
        songDetailTextField.inputView?.tag = 1
        themePicker.delegate = self
        songDetailPicker.delegate = self
        
        let themeRow = UserDefaults.standard.integer(forKey: "theme")
        themeTextField.text = themePickerData[themeRow].rawValue
        
        let defaultDatasourceText = DataSourceType.musicxmatch.rawValue
        songDetailTextField.text = UserDefaults.standard.string(forKey: "songDatasource") ?? defaultDatasourceText
    }
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1{
            return songDetailData.count
        }
        return themePickerData.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return songDetailData[row].rawValue
        } else {
            return themePickerData[row].rawValue
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        
        if pickerView.tag == 1 {
            let selectedDatasourceType = songDetailData[row]
            UserDefaults.standard.set(selectedDatasourceType.rawValue, forKey: "songDataSource")
            songDetailTextField.text = selectedDatasourceType.rawValue
        } else {

            let theme = ThemeSwitcher().switchThemes(row: row)
            themeTextField.text = themePickerData[row].rawValue
            
            UserDefaults.standard.set(Int(row), forKey: "theme")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(0.5)) {
                theme.apply(for: UIApplication.shared)
            }
        }
         self.view.endEditing(true)
        
    }
    
}

