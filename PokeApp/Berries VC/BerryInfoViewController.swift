//
//  BerryInfoViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 04/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class BerryInfoViewController: UIViewController {

    var selectedBerry: Items!
    var blurView: UIView!
    var blurEffectView: UIVisualEffectView!
    var activityIndicator: UIActivityIndicatorView!
    let themeDefault = UserDefaults.standard
    
    @IBOutlet weak var berryImage: UIImageView!
    @IBOutlet weak var berryNameLabel: UILabel!
    @IBOutlet weak var berryInfoView: UIView!
    @IBOutlet weak var firmnessLabel: UILabel!
    @IBOutlet weak var growthTimeLabel: UILabel!
    @IBOutlet weak var maxHarvestLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var smoothnessLabel: UILabel!
    @IBOutlet weak var giftPowerLabel: UILabel!
    @IBOutlet weak var giftTypeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // display berry name in the Navigation Bar title and a label
        self.title = selectedBerry.name
        self.berryNameLabel.text = selectedBerry.name
        
        loadBerryDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check from if dark theme is enabled
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch {
            darkTheme()
            berryInfoView.backgroundColor = Constants.Colors.gray40
            berryNameLabel.textColor = UIColor.white
            firmnessLabel.textColor = UIColor.white
            growthTimeLabel.textColor = UIColor.white
            maxHarvestLabel.textColor = UIColor.white
            sizeLabel.textColor = UIColor.white
            smoothnessLabel.textColor = UIColor.white
            giftPowerLabel.textColor = UIColor.white
            giftTypeLabel.textColor = UIColor.white
            // activity indicator
            activityIndicator.color = UIColor.white
        } else {
            lightTheme()
            berryInfoView.backgroundColor = UIColor.white
            berryNameLabel.textColor = UIColor.black
            berryNameLabel.textColor = UIColor.black
            firmnessLabel.textColor = UIColor.black
            growthTimeLabel.textColor = UIColor.black
            maxHarvestLabel.textColor = UIColor.black
            sizeLabel.textColor = UIColor.black
            smoothnessLabel.textColor = UIColor.black
            giftPowerLabel.textColor = UIColor.black
            giftTypeLabel.textColor = UIColor.black
            // activity indicator
            activityIndicator.color = UIColor.black
        }
    }
    
    func setLoadingView() {
        // create blur overlay
        blurView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.addSubview(blurView)
        
        let blurEffect: UIBlurEffect!
        
        // get theme mode
        let darkSwitch = themeDefault.bool(forKey: "themeDefault")
        
        if !UIAccessibility.isReduceTransparencyEnabled {
            blurView.backgroundColor = .clear
            if darkSwitch == true {
                blurEffect = UIBlurEffect(style: .dark)
            } else {
                blurEffect = UIBlurEffect(style: .light)
            }
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            // always fill the view
            blurEffectView.frame = blurView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurView.addSubview(blurEffectView)
        } else {
            if darkSwitch == true {
                blurView.backgroundColor = Constants.Colors.gray28
            } else {
                blurView.backgroundColor = .white
            }
        }
        
        // create activity indicator
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        // start activity indicator
        activityIndicator.startAnimating()
        // show activity indicator
        view.addSubview(activityIndicator)
    }
    
    private func loadBerryDetails() {
        setLoadingView()
        
        // get the move's details from the url of the selected move
        Alamofire.request(selectedBerry.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                
                // set the berry details from jsonDict
                self.selectedBerry.setBerryInfo(jsonObject: jsonDict)
                
                // display the firmness, growth time, max harvest, size, smoothness, gift power and gift type of the berry
                self.firmnessLabel.attributedText = self.attributedText(withString: String(format: "Firmness: %@", self.selectedBerry.firmness!), regularString: self.selectedBerry.firmness!, font: self.firmnessLabel.font)
                
                self.growthTimeLabel.attributedText = self.attributedText(withString: String(format: "Growth Time: %@", "\(self.selectedBerry.growthTime!)"), regularString: "\(self.selectedBerry.growthTime!)", font: self.growthTimeLabel.font)
                
                self.maxHarvestLabel.attributedText = self.attributedText(withString: String(format: "Max Harvest: %@", "\(self.selectedBerry.maxHarvest!)"), regularString: "\(self.selectedBerry.maxHarvest!)", font: self.maxHarvestLabel.font)
                
                self.sizeLabel.attributedText = self.attributedText(withString: String(format: "Size: %@", "\(self.selectedBerry.size!)"), regularString: "\(self.selectedBerry.size!)", font: self.sizeLabel.font)
                
                self.smoothnessLabel.attributedText = self.attributedText(withString: String(format: "Smoothness: %@", "\(self.selectedBerry.smoothness!)"), regularString: "\(self.selectedBerry.smoothness!)", font: self.smoothnessLabel.font)
                
                self.giftPowerLabel.attributedText = self.attributedText(withString: String(format: "Gift Power: %@", "\(self.selectedBerry.giftPower!)"), regularString: "\(self.selectedBerry.giftPower!)", font: self.giftPowerLabel.font)
                
                self.giftTypeLabel.attributedText = self.attributedText(withString: String(format: "Gift Type: %@", self.selectedBerry.giftType!), regularString: self.selectedBerry.giftType!, font: self.giftTypeLabel.font)
                
                // add berry name in sprite url
                let berryName = self.selectedBerry.name.lowercased().replacingOccurrences(of: " ", with: "-")
                let sprite = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/\(berryName)-berry.png"
                // get and display the sprite from the image link
                Alamofire.request(sprite).responseImage { response in
                    if let img = response.result.value {
                        self.berryImage.image = img
                    }
                    // stop activity indicator
                    self.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.6, animations: {
                        self.blurView.alpha = 0.0
                    })
                }
            }
        }
    }
}
