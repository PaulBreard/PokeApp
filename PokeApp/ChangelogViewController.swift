//
//  ChangelogViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 03/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit

class ChangelogViewController: UIViewController {

    @IBOutlet weak var appVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // show app version
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        appVersionLabel.text = "Version \(appVersion ?? "1.0")"
    }
}
