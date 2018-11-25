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
    
    var selectedItem: Pokemon!
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var blurImageView: UIView!
    @IBOutlet weak var itemImageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemCostLabel: UILabel!
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
                
                // get the item's cost
                guard let itemCost = jsonDict["cost"] as? Int
                    else {
                        return
                }
                // display results in the console
                print("Cost:", itemCost)
                
                // display the item's cost
                self.itemCostLabel.text = "₽\(itemCost)"
                
                // get the items attributes array
                guard let itemAttributesArray = jsonDict["attributes"] as? [[String: String]]
                    else {
                        return
                }
                var arrayOfAttributes: [String] = []
                // get all the attributes of the item
                for dic in itemAttributesArray {
                    let attributesName = dic["name"]

                    // create an array with the attributes of the selected item
                    arrayOfAttributes.append(attributesName!.capitalized)
                    // concatenate the attributes into a single string
                    let selectedItemAttributes = arrayOfAttributes.joined(separator: ", ")
                    
                    // display the attributes in the View Controller, wrap text and set number of lines
                    self.attributesLabel.text = selectedItemAttributes.replacingOccurrences(of: "-", with: " ")
                    self.attributesLabel.lineBreakMode = .byWordWrapping
                    self.attributesLabel.numberOfLines = 0
                    
                    // display results in the console
                    print("Attributes:", selectedItemAttributes)
                }
                
                // get the item's description dictionary
                guard let itemEffectArray = jsonDict["effect_entries"] as? [[String: Any]]
                    else {
                        return
                }
                // get the effect from the dictionary
                for dic in itemEffectArray {
                    let itemEffect = dic["effect"] as? String

                    // display the item's description in the View Controller, wrap text and set number of lines
                    self.itemEffectLabel.text = itemEffect?.replacingOccurrences(of: "\n:   ", with: ": \n").replacingOccurrences(of: "\n\n    ", with: "\n\n")
                    self.itemEffectLabel.lineBreakMode = .byWordWrapping
                    self.itemEffectLabel.numberOfLines = 0
                }
                
                // get the sprites dictionary
                guard let itemSprite = jsonDict["sprites"] as? [String: String],
                    // get one sprite link from the dictionary
                    let defaultSprite = itemSprite["default"]
                    else {
                        return
                }
                // display results in the console
                print("Sprite URL:", defaultSprite)
                
                // get and display the sprite from the link
                Alamofire.request(defaultSprite).responseImage { response in
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
