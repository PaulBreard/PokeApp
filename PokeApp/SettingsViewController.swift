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

    let gray40 = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0)
    let gray28 = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check from if dark theme is enabled
        let themeDefault = UserDefaults.standard
        darkSwitch.isOn = themeDefault.bool(forKey: "themeDefault")
        print(themeDefault.bool(forKey: "themeDefault"))

        // if dark theme is enabled, app theme will be dark
        if darkSwitch.isOn == true {
            darkTheme()
        }
        // if dark theme is not enabled, app theme will be light
        else {
            lightTheme()
        }

        // show app version
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        appVersionLabel.text = "Version \(appVersion ?? "1.0")"
    }
    
    func darkTheme() {
        UIView.animate(withDuration: 0.3, animations: {
            // view background color
            self.view.backgroundColor = self.gray28
            
            // navigation controller's background style, color and tint color
            self.navigationController?.navigationBar.barStyle = .black
            self.navigationController?.navigationBar.barTintColor = self.gray28
            self.navigationController?.navigationBar.tintColor = UIColor.white
            
            // tab bar controller's background style, color and tint color
            self.tabBarController?.tabBar.barStyle = .black
            self.tabBarController?.tabBar.barTintColor = self.gray28
            self.tabBarController?.tabBar.tintColor = UIColor.white
            
            // table view separator color
            self.tableView.separatorColor = UIColor.darkGray
            
            // cells background color
            self.themeModeCell.backgroundColor = self.gray40
            self.otherThemeOptionCell.backgroundColor = self.gray40
            self.comingSoonCell.backgroundColor = self.gray40
            self.versionCell.backgroundColor = self.gray40
            self.changelogCell.backgroundColor = self.gray40
            
            // cell text color
            self.themeModeLabel.textColor = UIColor.white
            self.otherThemeOptionLabel.textColor = UIColor.white
            self.comingSoonLabel.textColor = UIColor.white
            self.appVersionLabel.textColor = UIColor.white
            self.changelogLabel.textColor = UIColor.white
        })
    }
    
    func lightTheme() {
        UIView.animate(withDuration: 0.3, animations: {
            // view background color
            self.view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            
            // navigation controller's background style, color and tint color
            self.navigationController?.navigationBar.barStyle = .default
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.black
            
            // tab bar controller's background style, color and tint color
            self.tabBarController?.tabBar.barStyle = .default
            self.tabBarController?.tabBar.barTintColor = UIColor.white
            self.tabBarController?.tabBar.tintColor = UIColor.black
            
            // table view separator color
            self.tableView.separatorColor = UIColor.lightGray
            
            // cells background color
            self.themeModeCell.backgroundColor = UIColor.white
            self.otherThemeOptionCell.backgroundColor = UIColor.white
            self.comingSoonCell.backgroundColor = UIColor.white
            self.versionCell.backgroundColor = UIColor.white
            self.changelogCell.backgroundColor = UIColor.white
            
            // cell text color
            self.themeModeLabel.textColor = UIColor.black
            self.otherThemeOptionLabel.textColor = UIColor.black
            self.comingSoonLabel.textColor = UIColor.black
            self.appVersionLabel.textColor = UIColor.black
            self.changelogLabel.textColor = UIColor.black
        })
    }
    
    @IBAction func changeMode(_ sender: UISwitch) {
        if darkSwitch.isOn == true {
            darkTheme()
            
            // save in app
            let themeDefault = UserDefaults.standard
            themeDefault.set(true, forKey: "themeDefault")
        }
        if darkSwitch.isOn == false {
            lightTheme()
            
            // save in app
            let themeDefault = UserDefaults.standard
            themeDefault.set(false, forKey: "themeDefault")
        }
    }
    
}
