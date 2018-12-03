//
//  Constants.swift
//  PokeApp
//
//  Created by Paul BREARD on 18/10/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Foundation

struct Constants {
    struct PokeApi {
        static let pokeApi = "https://pokeapi.co/api/v2/pokemon/"
    }
    struct MoveApi {
        static let moveApi = "https://pokeapi.co/api/v2/move/"
    }
    struct BerryApi {
        static let berryApi = "https://pokeapi.co/api/v2/berry/"
    }
    struct ItemApi {
        static let itemApi = "https://pokeapi.co/api/v2/item/"
    }
    struct Colors {
        static let gray28 = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        static let gray40 = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        static let light = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        static let light200 = UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
    }
    struct Settings {
        static let themeDefault = UserDefaults.standard
    }
}

