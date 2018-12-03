//
//  Moves.swift
//  PokeApp
//
//  Created by Paul BREARD on 30/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import Foundation

struct Moves {
    var name: String
    var url: String
    var damage: String?
    var type: String?
    var accuracy: String?
    var powerPoints: String?
    var power: String?
    var effect: String?
    
    init?(pokeJson: [String: Any]) {
        // get all the moves
        guard let pokeMoveName = pokeJson["name"] as? String,
            let pokeMoveUrl = pokeJson["url"] as? String
            else {
                return nil
        }
        self.name = pokeMoveName.capitalized.replacingOccurrences(of: "-", with: " ")
        self.url = pokeMoveUrl
    }
    
    init?(moveJson: [String: Any]) {
        // get selected pokemon's moves
        guard let pokeMoves = moveJson["move"] as? [String: Any],
            let pokeMoveName = pokeMoves["name"] as? String,
            let pokeMoveUrl = pokeMoves["url"] as? String
            else {
                return nil
        }
        self.name = pokeMoveName.capitalized.replacingOccurrences(of: "-", with: " ")
        self.url = pokeMoveUrl
    }
    
    mutating func setMoveDetails(jsonObject: [String: Any]) {
        // get the damage class, type, accuracy, power points and power of the move
        guard let damageClassArray = jsonObject["damage_class"] as? [String: String],
            let damageClass = damageClassArray["name"],
            let moveTypeArray = jsonObject["type"] as? [String: String],
            let moveType = moveTypeArray["name"],
            let moveAccuracy = jsonObject["accuracy"] as? Int? ?? 0,
            let movePowerPoints = jsonObject["pp"] as? Int,
            let movePower = jsonObject["power"] as? Int? ?? 0
            else {
                return
        }
        damage = damageClass.capitalized
        type = moveType.capitalized
        accuracy = "\(moveAccuracy)%"
        powerPoints = "\(movePowerPoints)"
        power = "\(movePower)"
    }
    
    mutating func setMoveEffect(jsonObject : [String: Any]) {
        // get the move's effect dictionary
        guard let moveEffectArray = jsonObject["effect_entries"] as? [[String: Any]]
            else {
                return
        }
        // get the effect from the dictionary
        for dic in moveEffectArray {
            let moveEffect = dic["effect"] as? String
            // check if the effect's description has a chance variable
            if moveEffect!.contains("$effect_chance")  {
                // get the effect chance
                let effectChance = jsonObject["effect_chance"] as? Int
                // replace effect chance in the effect description by it's actual chance
                let moveEffectChance = moveEffect?.replacingOccurrences(of: "$effect_chance", with: "\(effectChance ?? 0)")
                // display the move's effect with its chance
                effect = moveEffectChance
            }
            else {
                // display the effect if it doesn't have a chance variable
                effect = moveEffect
            }
        }
    }
}
