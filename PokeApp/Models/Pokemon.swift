//
//  Pokemon.swift
//  PokeApp
//
//  Created by Paul BREARD on 18/10/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import Foundation

struct Pokemon:Codable {
    var name: String
    var url: String
    var id: Int
    var height: String?
    var weight: String?
    var defaultSprite: String?
    var shinySprite: String? = "error"
    var types: String?
    var typeOrTypes: Int?
    var abilities: String?
    
    init?(pokeJson: [String: Any]) {
        guard let pokeName = pokeJson["name"] as? String,
            let pokeUrl = pokeJson["url"] as? String
            else {
                return nil
        }
        name = pokeName.capitalized.replacingOccurrences(of: "Nidoran-M", with: "Nidoran ♂").replacingOccurrences(of: "Nidoran-F", with: "Nidoran ♀").replacingOccurrences(of: "-", with: " ")
        url = pokeUrl
        id = Int(url.split(separator: "/").last!)!
    }
    
    mutating func setSprites(jsonObject: [String: Any]) {
        // get the sprites dictionary
        guard let pokeSprite = jsonObject["sprites"] as? [String: Any],
            // get the default sprite's link from the dictionary
            let frontSprite = pokeSprite["front_default"] as? String? ?? "error",
            // get the shiny sprite's link from the dictionary
            let frontShinySprite = pokeSprite["front_shiny"] as? String? ?? "error"
            else {
                return
        }
        defaultSprite = frontSprite
        shinySprite = frontShinySprite
    }
    
    mutating func setTypes(jsonObject: [String: Any]) {
        // get the pokemon types array
        guard let pokeTypesArray = jsonObject["types"] as? [[String: Any]]
            else {
                return
        }
        var arrayOfPokeTypes: [String] = []
        // get all the types of the pokemon
        for dic in pokeTypesArray {
            let pokeType = dic["type"] as? [String: String]
            let pokeTypeName = pokeType!["name"]
            
            // create an array with the types of the selected pokemon
            arrayOfPokeTypes.append(pokeTypeName!.capitalized)
            // concatenate the types into a single string
            let selectedPokemonTypes = arrayOfPokeTypes.joined(separator: ", ")
            types = selectedPokemonTypes
        }
        typeOrTypes = arrayOfPokeTypes.count
    }
    
    mutating func setPhysicalAttributes(jsonObject: [String: Any]) {
        // get the height then the weight
        guard let pokeHeight = jsonObject["height"] as? Double,
            let pokeWeight = jsonObject["weight"] as? Double
            else {
                return
        }
        // divided by 10 to obtain correct values
        height = "\(pokeHeight/10) m"
        weight = "\(pokeWeight/10) kg"
    }
    
    mutating func setAbilities(jsonObject: [String: Any]) {
        // get the pokemon abilities array
        guard let pokeAbilitiesArray = jsonObject["abilities"] as? [[String: Any]]
            else {
                return
        }
        var arrayOfPokeAbilities: [String] = []
        // get all the abilities of the pokemon
        for dic in pokeAbilitiesArray {
            let pokeAbility = dic["ability"] as? [String: String]
            let pokeAbilityName = pokeAbility!["name"]
            
            // create an array with the abilities of the selected pokemon
            arrayOfPokeAbilities.append(pokeAbilityName!.capitalized)
            // concatenate the abilities into a single string
            var selectedPokemonAbilities = arrayOfPokeAbilities.joined(separator: ", ")
            selectedPokemonAbilities = selectedPokemonAbilities.replacingOccurrences(of: "-", with: " ")
            abilities = selectedPokemonAbilities
        }
    }
}
