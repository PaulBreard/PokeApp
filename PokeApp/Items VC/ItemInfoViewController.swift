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
    var activityIndicator: UIActivityIndicatorView!
    var blurView: UIView!
    var blurEffectView: UIVisualEffectView!
    let themeDefault = UserDefaults.standard
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemInfoView: UIView!
    @IBOutlet weak var itemCostLabel: UILabel!
    @IBOutlet weak var itemCategoryLabel: UILabel!
    @IBOutlet weak var attributesLabel: UILabel!
    @IBOutlet weak var itemEffectLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display item name in the Navigation Bar title and a label
        self.title = selectedItem.name
        itemNameLabel.text = selectedItem.name
        
        // adjusts font size of the name in the label to fit in the view if too long
        itemNameLabel.adjustsFontSizeToFitWidth = true
        itemNameLabel.lineBreakMode = .byClipping
        
        loadItemDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check from if dark theme is enabled
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch {
            darkTheme()
            itemNameLabel.textColor = UIColor.white
            itemCostLabel.textColor = UIColor.white
            itemCategoryLabel.textColor = UIColor.white
            attributesLabel.textColor = UIColor.white
            itemEffectLabel.textColor = UIColor.white
            itemInfoView.backgroundColor = Constants.Colors.gray40
            // activity indicator
            activityIndicator.color = UIColor.white
        } else {
            lightTheme()
            itemNameLabel.textColor = UIColor.black
            itemCostLabel.textColor = UIColor.black
            itemCategoryLabel.textColor = UIColor.black
            attributesLabel.textColor = UIColor.black
            itemEffectLabel.textColor = UIColor.black
            itemInfoView.backgroundColor = UIColor.white
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
    
    func loadItemDetails() {
        setLoadingView()
        
        // get the detail dictionary of the item from the url of the item
        Alamofire.request(selectedItem.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                
                // set the cost, attributes, description and sprite from jsonDict
                self.selectedItem.setCost(jsonObject: jsonDict)
                self.selectedItem.setCategory(jsonObject: jsonDict)
                self.selectedItem.setAttributes(jsonObject: jsonDict)
                self.selectedItem.setItemDescription(jsonObject: jsonDict)
                self.selectedItem.setSprite(jsonObject: jsonDict)
                
                // display the item's cost
                self.itemCostLabel.attributedText = self.attributedText(withString: String(format: "Cost: %@", self.selectedItem.cost!), regularString: self.selectedItem.cost!, font: self.itemCostLabel.font)
                
                // display the item's category
                self.itemCategoryLabel.attributedText = self.attributedText(withString: String(format: "Category: %@", self.selectedItem.category!), regularString: self.selectedItem.category!, font: self.itemCategoryLabel.font)
                
                // display the attributes in the View Controller, wrap text and set number of lines
                self.attributesLabel.attributedText = self.attributedText(withString: String(format: "Attributes: %@", self.selectedItem.attributes!), regularString: self.selectedItem.attributes!, font: self.attributesLabel.font)
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
                    self.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.6, animations: {
                        self.blurView.alpha = 0.0
                    })
                }
            }
        }
    }    
}
