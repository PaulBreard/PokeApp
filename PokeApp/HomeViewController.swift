//
//  HomeViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 26/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    let messageArray = ["Hi", "Welcome", "Hello", "What's up", "Hey", "Howdy"]
    let themeDefault = UserDefaults.standard
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var pokemonLabel: UILabel!
    @IBOutlet weak var pokemonView: UIView!
    @IBOutlet weak var berriesLabel: UILabel!
    @IBOutlet weak var berriesView: UIView!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var itemsView: UIView!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var movesView: UIView!
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var favoritesSubtitle: UILabel!
    @IBOutlet weak var favImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ask for user name if not set
        let userName = themeDefault.string(forKey: "UserName")
        if userName == "" || userName == nil {
            let alert = UIAlertController(title: "Hi! What's your name?", message: "You can edit it in the settings later", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "Enter your name here"
            })
            alert.addAction(UIAlertAction(title: "Done!", style: .default) { action in
                let userNameAlert = alert.textFields?.first?.text?.capitalized
                Constants.Settings.themeDefault.set(userNameAlert, forKey: "UserName")
                self.setWelcome()
            })
            alert.addAction(UIAlertAction(title: "Not now", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else {
            setWelcome()
        }
        
        // set default favorite subtitle
        favoritesSubtitle.text = "You have no favorites"
        
        // set favorited icon to white
        favImage.image = favImage.image!.withRenderingMode(.alwaysTemplate)
        favImage.tintColor = UIColor.white
        
        // adjusts font size of labels to fit in the view
        pokemonLabel.adjustsFontSizeToFitWidth = true
        pokemonLabel.lineBreakMode = .byClipping
        berriesLabel.adjustsFontSizeToFitWidth = true
        berriesLabel.lineBreakMode = .byClipping
        itemsLabel.adjustsFontSizeToFitWidth = true
        itemsLabel.lineBreakMode = .byClipping
        movesLabel.adjustsFontSizeToFitWidth = true
        movesLabel.lineBreakMode = .byClipping
        favoritesSubtitle.lineBreakMode = .byWordWrapping
    }
    
    func setWelcome() {
        let welcomeUserName = Constants.Settings.themeDefault.string(forKey: "UserName")
        // calculate a random number in the range of the message array
        let randomNumber = Int(arc4random()) % messageArray.count
        welcomeLabel.text = "\(messageArray[randomNumber]) \(welcomeUserName ?? "")"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check is dark mode is enabled
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch == true {
            darkTheme()
            welcomeLabel.textColor = .white
            subtitleLabel.textColor = .lightGray
        } else {
            lightTheme()
            welcomeLabel.textColor = .black
            subtitleLabel.textColor = .darkGray
        }
        
        // check favArray to show how many pokémon are in the favorites
        if let data = themeDefault.value(forKey:"FavPokemon") as? Data {
            let favArray = try! PropertyListDecoder().decode([Pokemon].self, from: data)
            if favArray.count >= 1 {
                favoritesSubtitle.text = "You have \(favArray.count) Pokémon to your favorites"
            } else {
                favoritesSubtitle.text = "You have no favorites"
            }
        }
        
        setWelcome()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pokemonView.dropShadow()
        berriesView.dropShadow()
        itemsView.dropShadow()
        movesView.dropShadow()
        favoritesView.dropShadow()
    }
}
