//
//  SettingsTableViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 25/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var darkSwitch: UISwitch!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var themeModeCell: UITableViewCell!
    @IBOutlet weak var otherThemeOptionCell: UITableViewCell!
    @IBOutlet weak var comingSoonCell: UITableViewCell!
    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var changelogCell: UITableViewCell!
    @IBOutlet weak var themeModeLabel: UILabel!
    @IBOutlet weak var otherThemeOptionLabel: UILabel!
    @IBOutlet weak var comingSoonLabel: UILabel!
    @IBOutlet weak var changelogLabel: UILabel!
    
    let customSelectedCellColor = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check from if dark theme is enabled
        darkSwitch.isOn = Constants.Settings.themeDefault.bool(forKey: "themeDefault")

        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch.isOn == true {
            darkTheme()
            darkThemeSettings()
        }
        else {
            lightTheme()
            lightThemeSettings()
        }

        // show app version
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        appVersionLabel.text = "Version \(appVersion ?? "1.0") (\(buildNumber))"
    }
    
    func darkThemeSettings() {
        // table view separator color
        tableView.separatorColor = UIColor.darkGray

        // cells background color
        themeModeCell.backgroundColor = Constants.Colors.gray40
        otherThemeOptionCell.backgroundColor = Constants.Colors.gray40
        comingSoonCell.backgroundColor = Constants.Colors.gray40
        versionCell.backgroundColor = Constants.Colors.gray40
        changelogCell.backgroundColor = Constants.Colors.gray40

        // cell text color
        themeModeLabel.textColor = UIColor.white
        otherThemeOptionLabel.textColor = UIColor.white
        comingSoonLabel.textColor = UIColor.white
        appVersionLabel.textColor = UIColor.white
        changelogLabel.textColor = UIColor.white
    
        // change the selected cell background color
        customSelectedCellColor.backgroundColor = UIColor.darkGray
        changelogCell.selectedBackgroundView = customSelectedCellColor
    }
    
    func lightThemeSettings() {
        // table view separator color
        tableView.separatorColor = UIColor.lightGray

        // cells background color
        themeModeCell.backgroundColor = UIColor.white
        otherThemeOptionCell.backgroundColor = UIColor.white
        comingSoonCell.backgroundColor = UIColor.white
        versionCell.backgroundColor = UIColor.white
        changelogCell.backgroundColor = UIColor.white

        // cell text color
        themeModeLabel.textColor = UIColor.black
        otherThemeOptionLabel.textColor = UIColor.black
        comingSoonLabel.textColor = UIColor.black
        appVersionLabel.textColor = UIColor.black
        changelogLabel.textColor = UIColor.black
        
        // change the selected cell background color
        customSelectedCellColor.backgroundColor = UIColor.lightGray
        changelogCell.selectedBackgroundView = customSelectedCellColor
    }
    
    @IBAction func changeMode(_ sender: UISwitch) {
        if darkSwitch.isOn == true {
            darkTheme()
            darkThemeSettings()
            
            // save in app
            let themeDefault = UserDefaults.standard
            themeDefault.set(true, forKey: "themeDefault")
        }
        if darkSwitch.isOn == false {
            lightTheme()
            lightThemeSettings()
            
            // save in app
            let themeDefault = UserDefaults.standard
            themeDefault.set(false, forKey: "themeDefault")
        }
    }
    
}
