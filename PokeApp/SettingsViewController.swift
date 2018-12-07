//
//  SettingsTableViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 25/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var darkSwitch: UISwitch!
    @IBOutlet weak var userNameCell: UITableViewCell!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var themeModeCell: UITableViewCell!
    @IBOutlet weak var comingSoonCell: UITableViewCell!
    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var themeModeLabel: UILabel!
    @IBOutlet weak var comingSoonLabel: UILabel!
    
    let customSelectedCellColor = UIView()
    let themeDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set user name if it already exists
        userNameTextField.text = themeDefault.string(forKey: "UserName")
        
        // check from if dark theme is enabled
        darkSwitch.isOn = Constants.Settings.themeDefault.bool(forKey: "themeDefault")

        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch.isOn == true {
            darkTheme()
            darkThemeSettings()
        } else {
            lightTheme()
            lightThemeSettings()
        }
        
        // set the cell height
        tableView.rowHeight = 44.0
        
        // show app version
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        appVersionLabel.text = "Version \(appVersion ?? "1.0") (\(buildNumber))"
        
        userNameTextField.delegate = self
    }

    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        // dismiss keyboard when return key is hit
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func setUserName(_ sender: Any) {
        let userName = userNameTextField.text
        themeDefault.set(userName, forKey: "UserName")
    }
    
    func darkThemeSettings() {
        // table view separator color
        tableView.separatorColor = .darkGray

        // cells background color
        userNameCell.backgroundColor = Constants.Colors.gray40
        themeModeCell.backgroundColor = Constants.Colors.gray40
        comingSoonCell.backgroundColor = Constants.Colors.gray40
        versionCell.backgroundColor = Constants.Colors.gray40

        // cell text color
        userNameLabel.textColor = .white
        userNameTextField.textColor = .white
        userNameTextField.setValue(UIColor.lightGray, forKeyPath: "placeholderLabel.textColor")
        themeModeLabel.textColor = .white
        comingSoonLabel.textColor = .white
        appVersionLabel.textColor = .white
    }
    
    func lightThemeSettings() {
        // table view separator color
        tableView.separatorColor = .lightGray

        // cells background color
        userNameCell.backgroundColor = .white
        themeModeCell.backgroundColor = .white
        comingSoonCell.backgroundColor = .white
        versionCell.backgroundColor = .white

        // cell text color
        userNameLabel.textColor = .black
        userNameTextField.textColor = .black
        userNameTextField.setValue(UIColor.darkGray, forKeyPath: "placeholderLabel.textColor")
        themeModeLabel.textColor = .black
        comingSoonLabel.textColor = .black
        appVersionLabel.textColor = .black
    }
    
    @IBAction func changeMode(_ sender: UISwitch) {
        if darkSwitch.isOn == true {
            darkTheme()
            darkThemeSettings()
            // save in app
            themeDefault.set(true, forKey: "themeDefault")
        }
        if darkSwitch.isOn == false {
            lightTheme()
            lightThemeSettings()
            // save in app
            themeDefault.set(false, forKey: "themeDefault")
        }
    }
    
}
