//
//  Pokemon.swift
//  PokeApp
//
//  Created by Paul BREARD on 18/10/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import Foundation

// usued for Pokémon, Moves, Berries and Items
struct Pokemon {
    let name: String
    let url: String
    
    init?(pokeJson: [String: Any]) {
        guard let pokeName = pokeJson["name"] as? String,
            let pokeUrl = pokeJson["url"] as? String
        else {
                return nil
        }
        self.name = pokeName.capitalized.replacingOccurrences(of: "Nidoran-M", with: "Nidoran ♂").replacingOccurrences(of: "Nidoran-F", with: "Nidoran ♀").replacingOccurrences(of: "-", with: " ")
        self.url = pokeUrl
    }
}

struct PokemonMoves {
    let moveName: String
    let moveUrl: String
    
    init?(pokeJson: [String: Any]) {
        guard let pokeMove = pokeJson["move"] as? [String: String],
            let pokeMoveName = pokeMove["name"],
            let pokeMoveUrl = pokeMove["url"]
            else {
                return nil
        }
        self.moveName = pokeMoveName.capitalized.replacingOccurrences(of: "-", with: " ")
        self.moveUrl = pokeMoveUrl
    }
}
