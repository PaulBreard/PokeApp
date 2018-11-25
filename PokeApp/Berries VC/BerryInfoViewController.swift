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

    var selectedBerry: Pokemon!
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var berryInfoActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var berryNameLabel: UILabel!
    @IBOutlet weak var berryFirmnessLabel: UILabel!
    @IBOutlet weak var berryGrowthTimeLabel: UILabel!
    @IBOutlet weak var berryMaxHarvestLabel: UILabel!
    @IBOutlet weak var berrySizeLabel: UILabel!
    @IBOutlet weak var berrySmoothnessLabel: UILabel!
    @IBOutlet weak var berryGiftPowerLabel: UILabel!
    @IBOutlet weak var berryGiftTypeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = selectedBerry.name
        self.berryNameLabel.text = selectedBerry.name
        
        loadBerryDetails()
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
                
                // get the firmness, growth time, max harvest, size, smoothness, gift power and gift type of the berry
                guard let berryFirmnessArray = jsonDict["firmness"] as? [String: String],
                    let berryFirmness = berryFirmnessArray["name"],
                    let berryGrowthTime = jsonDict["growth_time"] as? Int? ?? 0,
                    let berryMaxHarvest = jsonDict["max_harvest"] as? Int? ?? 0,
                    let berrySize = jsonDict["size"] as? Int? ?? 0,
                    let berrySmoothness = jsonDict["smoothness"] as? Int? ?? 0,
                    let berryGiftPower = jsonDict["natural_gift_power"] as? Int? ?? 0,
                    let berryGiftTypeArray = jsonDict["natural_gift_type"] as? [String: String],
                    let berryGiftType = berryGiftTypeArray["name"]
                else {
                    return
                }
                
                // display the firmness, growth time, max harvest, size, smoothness, gift power and gift type of the berry
                self.berryFirmnessLabel.text = berryFirmness.capitalized.replacingOccurrences(of: "-", with: " ")
                self.berryGrowthTimeLabel.text = "\(berryGrowthTime)"
                self.berryMaxHarvestLabel.text = "\(berryMaxHarvest)"
                self.berrySizeLabel.text = "\(berrySize)"
                self.berrySmoothnessLabel.text = "\(berrySmoothness)"
                self.berryGiftPowerLabel.text = "\(berryGiftPower)"
                self.berryGiftTypeLabel.text = berryGiftType.capitalized
                
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
