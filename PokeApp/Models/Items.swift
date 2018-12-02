//
//  Items.swift
//  PokeApp
//
//  Created by Paul BREARD on 29/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import Foundation

// used for items and berries
struct Items {
    let name: String
    let url: String
    
    // items details
    var sprite: String?
    var cost: Int?
    var attributes: String?
    var description: String?
    
    // berries details
    var firmness: String?
    var growthTime: String?
    var maxHarvest: Int?
    var size: String?
    var smoothness: Int?
    var giftPower: Int?
    var giftType: String?
    
    init?(pokeJson: [String: Any]) {
        guard let itemName = pokeJson["name"] as? String,
            let itemUrl = pokeJson["url"] as? String
            else {
                return nil
        }
        self.name = itemName.capitalized.replacingOccurrences(of: "-", with: " ")
        self.url = itemUrl
    }
    
    mutating func setSprite(jsonObject: [String: Any]) {
        // get the sprites dictionary
        guard let itemSprite = jsonObject["sprites"] as? [String: Any],
            // get one sprite link from the dictionary
            let defaultSprite = itemSprite["default"] as? String
            else {
                return
        }
        sprite = defaultSprite
    }
    
    mutating func setCost(jsonObject: [String: Any]) {
        // get the item's cost
        guard let itemCost = jsonObject["cost"] as? Int
            else {
                return
        }
        cost = itemCost
    }
    
    mutating func setAttributes(jsonObject: [String: Any]) {
        // get the items attributes array
        guard let itemAttributesArray = jsonObject["attributes"] as? [[String: String]]
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
            
            attributes = selectedItemAttributes.replacingOccurrences(of: "-", with: " ")
        }
    }
    
    mutating func setItemDescription(jsonObject: [String: Any]) {
        // get the item's description dictionary
        guard let itemEffectArray = jsonObject["effect_entries"] as? [[String: Any]]
            else {
                return
        }
        // get the effect from the dictionary
        for dic in itemEffectArray {
            let itemEffect = dic["effect"] as? String
            
            description = itemEffect?.replacingOccurrences(of: "\n:   ", with: ": \n").replacingOccurrences(of: "\n\n    ", with: "\n\n")
        }
    }
    
    mutating func setBerryInfo(jsonObject : [String: Any]) {
        // get the firmness, growth time, max harvest, size, smoothness, gift power and gift type of the berry
        guard let berryFirmnessArray = jsonObject["firmness"] as? [String: String],
            let berryFirmness = berryFirmnessArray["name"],
            let berryGrowthTime = jsonObject["growth_time"] as? Int? ?? 0,
            let berryMaxHarvest = jsonObject["max_harvest"] as? Int? ?? 0,
            let berrySize = jsonObject["size"] as? Double? ?? 0,
            let berrySmoothness = jsonObject["smoothness"] as? Int? ?? 0,
            let berryGiftPower = jsonObject["natural_gift_power"] as? Int? ?? 0,
            let berryGiftTypeArray = jsonObject["natural_gift_type"] as? [String: String],
            let berryGiftType = berryGiftTypeArray["name"]
            else {
                return
        }
        firmness = berryFirmness.capitalized.replacingOccurrences(of: "-", with: " ")
        growthTime = "\(berryGrowthTime) hours"
        maxHarvest = berryMaxHarvest
        size = "\(berrySize/10) cm"
        smoothness = berrySmoothness
        giftPower = berryGiftPower
        giftType = berryGiftType.capitalized
    }
}
