//
//  PokemonDetails.swift
//  PokeApp
//
//  Created by Paul BREARD on 27/10/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import Foundation

struct PokemonTypes {
    let pokemonType: String
    
    var arrayOfPokeTypes: [String] = []
    init?(pokeJson: [String: Any]) {
        // get the pokemon types
        guard let pokeType = pokeJson["type"] as? [String: String],
            let pokeTypeName = pokeType["name"]
        else {
            return nil
        }
        // create an array with the types of the selected pokemon
        arrayOfPokeTypes.append(pokeTypeName.capitalized)
        // concatenate the types into a single string
        let selectedPokemonTypes = arrayOfPokeTypes.joined(separator: ", ")

        self.pokemonType = selectedPokemonTypes
    }
}

struct PokemonAbilities {
    let pokemonAbility: String
    
    var arrayOfPokeAbilities: [String] = []
    init?(pokeJson: [String: Any]) {
        // get the pokemon types
        guard let pokeAbility = pokeJson["ability"] as? [String: String],
            let pokemonAbility = pokeAbility["name"]
            else {
                return nil
        }
        // create an array with the abilities of the selected pokemon
        arrayOfPokeAbilities.append(pokemonAbility.capitalized)
        // concatenate the abilities into a single string
        let selectedPokemonAbilities = arrayOfPokeAbilities.joined(separator: ", ")
        
        self.pokemonAbility = selectedPokemonAbilities
    }
}

struct PokemonSprites {
    let frontSprite: String
    let frontShinySprite: String
    
    init?(pokeJson: [String: String]) {
        // get the pokemon sprites
        guard let frontSprite = pokeJson["front_default"],
            // get the shiny sprite's link from the dictionary
            let frontShinySprite = pokeJson["front_shiny"]
            else {
                return nil
        }
        self.frontSprite = frontSprite
        self.frontShinySprite = frontShinySprite
    }
}
