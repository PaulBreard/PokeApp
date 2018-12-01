//
//  BerryInfoViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 04/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Alamofire

class BerryInfoViewController: UIViewController {

    var selectedBerry: Items!
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var berryInfoActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var berryNameLabel: UILabel!
    @IBOutlet weak var berryInfoView: UIView!
    @IBOutlet weak var berryFirmness: UILabel!
    @IBOutlet weak var berryFirmnessLabel: UILabel!
    @IBOutlet weak var berryGrowthTime: UILabel!
    @IBOutlet weak var berryGrowthTimeLabel: UILabel!
    @IBOutlet weak var berryMaxHarvest: UILabel!
    @IBOutlet weak var berryMaxHarvestLabel: UILabel!
    @IBOutlet weak var berrySize: UILabel!
    @IBOutlet weak var berrySizeLabel: UILabel!
    @IBOutlet weak var berrySmoothness: UILabel!
    @IBOutlet weak var berrySmoothnessLabel: UILabel!
    @IBOutlet weak var berryGiftPower: UILabel!
    @IBOutlet weak var berryGiftPowerLabel: UILabel!
    @IBOutlet weak var berryGiftType: UILabel!
    @IBOutlet weak var berryGiftTypeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = selectedBerry.name
        self.berryNameLabel.text = selectedBerry.name
        
        loadBerryDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check from if dark theme is enabled
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch == true {
            darkTheme()
            berryInfoView.backgroundColor = Constants.Colors.gray40
            berryNameLabel.textColor = UIColor.white
            berryFirmness.textColor = UIColor.white
            berryFirmnessLabel.textColor = UIColor.white
            berryGrowthTime.textColor = UIColor.white
            berryGrowthTimeLabel.textColor = UIColor.white
            berryMaxHarvest.textColor = UIColor.white
            berryMaxHarvestLabel.textColor = UIColor.white
            berrySize.textColor = UIColor.white
            berrySizeLabel.textColor = UIColor.white
            berrySmoothness.textColor = UIColor.white
            berrySmoothnessLabel.textColor = UIColor.white
            berryGiftPower.textColor = UIColor.white
            berryGiftPowerLabel.textColor = UIColor.white
            berryGiftType.textColor = UIColor.white
            berryGiftTypeLabel.textColor = UIColor.white
        } else {
            lightTheme()
            berryInfoView.backgroundColor = UIColor.white
            berryNameLabel.textColor = UIColor.black
            berryNameLabel.textColor = UIColor.black
            berryFirmness.textColor = UIColor.black
            berryFirmnessLabel.textColor = UIColor.black
            berryGrowthTime.textColor = UIColor.black
            berryGrowthTimeLabel.textColor = UIColor.black
            berryMaxHarvest.textColor = UIColor.black
            berryMaxHarvestLabel.textColor = UIColor.black
            berrySize.textColor = UIColor.black
            berrySizeLabel.textColor = UIColor.black
            berrySmoothness.textColor = UIColor.black
            berrySmoothnessLabel.textColor = UIColor.black
            berryGiftPower.textColor = UIColor.black
            berryGiftPowerLabel.textColor = UIColor.black
            berryGiftType.textColor = UIColor.black
            berryGiftTypeLabel.textColor = UIColor.black
        }
    }
    
    private func loadBerryDetails() {
        // start activity indicator
        berryInfoActivityIndicator.startAnimating()
        // blur overlay while loading data
        if !UIAccessibility.isReduceTransparencyEnabled {
            self.blurView.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            // always fill the view
            blurEffectView.frame = self.blurView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blurView.addSubview(blurEffectView)
        } else {
            self.blurView.backgroundColor = .black
        }
        
        // get the move's details from the url of the selected move
        Alamofire.request(selectedBerry.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                
                // set the berry details from jsonDict
                self.selectedBerry.setBerryInfo(jsonObject: jsonDict)
                
                // display the firmness, growth time, max harvest, size, smoothness, gift power and gift type of the berry
                self.berryFirmnessLabel.text = self.selectedBerry.firmness!
                self.berryGrowthTimeLabel.text = "\(self.selectedBerry.growthTime!)"
                self.berryMaxHarvestLabel.text = "\(self.selectedBerry.maxHarvest!)"
                self.berrySizeLabel.text = "\(self.selectedBerry.size!)"
                self.berrySmoothnessLabel.text = "\(self.selectedBerry.smoothness!)"
                self.berryGiftPowerLabel.text = "\(self.selectedBerry.giftPower!)"
                self.berryGiftTypeLabel.text = self.selectedBerry.giftType!
                
                // stop activity indicator
                self.berryInfoActivityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.6, animations: {
                    self.blurView.alpha = 0.0
                    self.loadingLabel.isHidden = true
                })
            }
        }
    }


}
