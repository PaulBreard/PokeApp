//
//  ItemInfoViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 04/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ItemInfoViewController: UIViewController {
    
    var selectedItem: Items!
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var blurImageView: UIView!
    @IBOutlet weak var itemImageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemInfoView: UIView!
    @IBOutlet weak var itemCost: UILabel!
    @IBOutlet weak var itemCostLabel: UILabel!
    @IBOutlet weak var attributes: UILabel!
    @IBOutlet weak var attributesLabel: UILabel!
    @IBOutlet weak var itemEffectLabel: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var itemInfoActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display item name in the Navigation Bar title and a label
        self.title = selectedItem.name
        itemNameLabel.text = selectedItem.name
        
        // adjusts font size of the name in the label to fit in the view if too long
        itemNameLabel.adjustsFontSizeToFitWidth = true
        itemNameLabel.lineBreakMode = .byClipping
        
        // overlay on item image
        self.blurImageView.alpha = 0.0
        
        loadItemDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check from if dark theme is enabled
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch == true {
            darkTheme()
            itemNameLabel.textColor = UIColor.white
            itemCost.textColor = UIColor.white
            itemCostLabel.textColor = UIColor.white
            attributes.textColor = UIColor.white
            attributesLabel.textColor = UIColor.white
            itemEffectLabel.textColor = UIColor.white
            itemInfoView.backgroundColor = Constants.Colors.gray40
        } else {
            lightTheme()
            itemNameLabel.textColor = UIColor.black
            itemCost.textColor = UIColor.black
            itemCostLabel.textColor = UIColor.black
            attributes.textColor = UIColor.black
            attributesLabel.textColor = UIColor.black
            itemEffectLabel.textColor = UIColor.black
            itemInfoView.backgroundColor = UIColor.white
        }
    }
    
    func loadItemDetails() {
        // start activity indicator
        itemInfoActivityIndicator.startAnimating()
        itemImageActivityIndicator.startAnimating()
        // blur overlay while loading data
        if !UIAccessibility.isReduceTransparencyEnabled {
            self.blurView.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.blurView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blurView.addSubview(blurEffectView)
        } else {
            self.blurView.backgroundColor = .black
        }
        
        // get the detail dictionary of the item from the url of the item
        Alamofire.request(selectedItem.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                
                // set the cost, attributes, description and sprite from jsonDict
                self.selectedItem.setCost(jsonObject: jsonDict)
                self.selectedItem.setAttributes(jsonObject: jsonDict)
                self.selectedItem.setItemDescription(jsonObject: jsonDict)
                self.selectedItem.setSprite(jsonObject: jsonDict)
                
                // display the item's cost
                self.itemCostLabel.text = "₽\(self.selectedItem.cost!)"
                
                // display the attributes in the View Controller, wrap text and set number of lines
                self.attributesLabel.text = self.selectedItem.attributes!
                self.attributesLabel.lineBreakMode = .byWordWrapping
                self.attributesLabel.numberOfLines = 0
                
                // display the item's description in the View Controller, wrap text and set number of lines
                self.itemEffectLabel.text = self.selectedItem.description!
                self.itemEffectLabel.lineBreakMode = .byWordWrapping
                self.itemEffectLabel.numberOfLines = 0
                
                // get and display the sprite from the link
                Alamofire.request(self.selectedItem.sprite!).responseImage { response in
                    if let img = response.result.value {
                        self.itemImage.image = img
                    }
                    // stop activity indicator
                    self.itemImageActivityIndicator.stopAnimating()
                    self.itemInfoActivityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.6, animations: {
                        self.blurView.alpha = 0.0
                        self.loadingLabel.isHidden = true
                    })
                }
            }
        }
    }
    
}
