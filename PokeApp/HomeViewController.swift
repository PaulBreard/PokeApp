//
//  HomeViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 26/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check from if dark theme is enabled
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch == true {
            darkTheme()
        }
        else {
            lightTheme()
        }
    }
}
