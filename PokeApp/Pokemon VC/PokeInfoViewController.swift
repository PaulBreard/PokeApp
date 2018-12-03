//
//  PokeInfoViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 26/10/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class PokeInfoController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedPokemon: Pokemon!
    var pokeMovesArray = [Moves]()
    var isShiny: Bool = false

    @IBOutlet weak var pokeNameLabel: UILabel!
    @IBOutlet weak var pokeTypeLabel: UILabel!
    @IBOutlet weak var pokeImage: UIImageView!
    @IBOutlet weak var pokeImageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pokeInfoView: UIView!
    @IBOutlet weak var pokeHeightLabel: UILabel!
    @IBOutlet weak var pokeWeightLabel: UILabel!
    @IBOutlet weak var pokeAbilitiesLabel: UILabel!
    @IBOutlet weak var changeSpriteLabel: UIButton!
    @IBOutlet weak var pokeMovesViewButton: UIButton!
    @IBOutlet weak var pokeMoveTableView: UITableView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display pokemon name in the Navigation Bar title and a label
        self.title = selectedPokemon.name
        pokeNameLabel.text = selectedPokemon.name
        // adjusts font size of the name in the label to fit in the view if too long
        pokeNameLabel.adjustsFontSizeToFitWidth = true
        pokeNameLabel.lineBreakMode = .byClipping
        
        // set background color of the button to orange
        self.changeSpriteLabel.backgroundColor = UIColor.orange
        
        // set round top corners to something
        // bug: element's width do not change when holding device in landscape mode
        // self.add something here.roundCorners([.topLeft, .topRight], radius: 4)
        
        // hide pokemon moves table view
        self.pokeMoveTableView.isHidden = true
        
        pokeImageActivityIndicator.stopAnimating()
        
        loadPokemonDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check from if dark theme is enabled
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch == true {
            darkTheme()
            darkThemePoke()
        } else {
            lightTheme()
            lightThemePoke()
        }
        // update table view UI
        pokeMoveTableView.reloadData()
        
        // auto deselect cells
        if let index = self.pokeMoveTableView.indexPathForSelectedRow {
            self.pokeMoveTableView.deselectRow(at: index, animated: true)
        }
    }
    
    func darkThemePoke() {
        pokeNameLabel.textColor = UIColor.white
        pokeTypeLabel.textColor = UIColor.white
        pokeHeightLabel.textColor = UIColor.white
        pokeWeightLabel.textColor = UIColor.white
        pokeAbilitiesLabel.textColor = UIColor.white
        pokeInfoView.backgroundColor = Constants.Colors.gray40

        // activity indicator
        activityIndicator.color = UIColor.white
        loadingLabel.textColor = UIColor.white
        pokeImageActivityIndicator.color = UIColor.white
        
        // table view separator and background color
        pokeMoveTableView.separatorColor = UIColor.darkGray
        pokeMoveTableView.backgroundColor = Constants.Colors.gray40
    }
    
    func lightThemePoke() {
        pokeNameLabel.textColor = UIColor.black
        pokeTypeLabel.textColor = UIColor.black
        pokeHeightLabel.textColor = UIColor.black
        pokeWeightLabel.textColor = UIColor.black
        pokeAbilitiesLabel.textColor = UIColor.black
        pokeInfoView.backgroundColor = UIColor.white
        
        // activity indicator
        activityIndicator.color = UIColor.black
        loadingLabel.textColor = UIColor.black
        pokeImageActivityIndicator.color = UIColor.black

        // table view separator and background color
        pokeMoveTableView.separatorColor = UIColor.lightGray
        pokeMoveTableView.backgroundColor = UIColor.white
    }
    
    private func loadPokemonDetails() {
        // start activity indicator
        activityIndicator.startAnimating()
        // blur overlay while loading data
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        if !UIAccessibility.isReduceTransparencyEnabled {
            self.blurView.backgroundColor = .clear
            if darkSwitch == true {
                let blurEffect = UIBlurEffect(style: .dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                // always fill the view
                blurEffectView.frame = self.blurView.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.blurView.addSubview(blurEffectView)
            } else {
                let blurEffect = UIBlurEffect(style: .light)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                // always fill the view
                blurEffectView.frame = self.blurView.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.blurView.addSubview(blurEffectView)
            }
        } else {
            if darkSwitch == true {
                self.blurView.backgroundColor = Constants.Colors.gray28
            } else {
                self.blurView.backgroundColor = .white
            }
        }

        // get the detail dictionary of the pokemon from the url of the pokemon
        Alamofire.request(selectedPokemon.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                
                // set the sprites, types, height, weight and abilities from jsonDict for the selected pokemon
                self.selectedPokemon.setSprites(jsonObject: jsonDict)
                self.selectedPokemon.setTypes(jsonObject: jsonDict)
                self.selectedPokemon.setPhysicalAttributes(jsonObject: jsonDict)
                self.selectedPokemon.setAbilities(jsonObject: jsonDict)
                
                // update UI from the selectedPokemon
                // get and display the sprite from the link
                if self.selectedPokemon.defaultSprite! != "error" {
                    Alamofire.request(self.selectedPokemon.defaultSprite!).responseImage { response in
                        if let img = response.result.value {
                            self.pokeImage.image = img
                        }
                    }
                } else {
                    let placeholderImage: UIImage = UIImage(named: "Placeholder")!
                    self.pokeImage.image = placeholderImage
                }
                // display the pokemon height and weight
                self.pokeHeightLabel.attributedText = self.attributedText(withString: String(format: "Height: %@", self.selectedPokemon.height!), regularString: self.selectedPokemon.height!, font: self.pokeHeightLabel.font)
                
                self.pokeWeightLabel.attributedText = self.attributedText(withString: String(format: "Weight: %@", self.selectedPokemon.weight!), regularString: self.selectedPokemon.weight!, font: self.pokeWeightLabel.font)
                
                // display the types
                self.pokeTypeLabel.attributedText = self.attributedText(withString: String(format: self.typeTypes(), self.selectedPokemon.types!), regularString: self.selectedPokemon.types!, font: self.pokeTypeLabel.font)
                
                // display the abilities
                self.pokeAbilitiesLabel.attributedText = self.attributedText(withString: String(format: "Abilities: %@", self.selectedPokemon.abilities!), regularString: self.selectedPokemon.abilities!, font: self.pokeAbilitiesLabel.font)
                self.pokeAbilitiesLabel.lineBreakMode = .byWordWrapping
                self.pokeAbilitiesLabel.numberOfLines = 0
                
                // get and display the selected pokemon's moves
                if let pokeMoves = jsonDict["moves"] as? [[String: Any]] {
                    self.pokeMovesArray = pokeMoves.map { moveJson -> Moves in
                        return Moves(moveJson: moveJson)!
                    }
                    // tell UITable View to reload UI from the poke moves array
                    self.pokeMoveTableView.reloadData()
                    // display the number of moves above the TableView
                    self.pokeMovesViewButton.setTitle("\(self.selectedPokemon.name) has \(self.pokeMovesArray.count) moves ↓", for: .normal)
                    
                    // auto adjust font size if the text is too long
                    self.pokeMovesViewButton.titleLabel?.numberOfLines = 1
                    self.pokeMovesViewButton.titleLabel?.adjustsFontSizeToFitWidth = true
                    self.pokeMovesViewButton.titleLabel?.lineBreakMode = .byClipping
                }
                
                // stop activity indicator
                self.activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.6, animations: {
                    self.blurView.alpha = 0.0
                    self.loadingLabel.isHidden = true
                })
            }
        }
    }
    
    func typeTypes() -> String {
        // writes Types when pokemon has several types and Type when it has only one
        if self.selectedPokemon.typeOrTypes! > 1 {
            let typeOrTypes = "Types: %@"
            return typeOrTypes
        }
        else {
            let typeOrTypes = "Type: %@"
            return typeOrTypes
        }
    }
    
    @IBAction func pokeMovesButton(_ sender: Any) {
        UIStackView.animateVisibilityOfViews([pokeMoveTableView], hidden: !pokeMoveTableView.isHidden)
        if pokeMoveTableView.isHidden == true {
            // change the button's text
            self.pokeMovesViewButton.setTitle("\(self.selectedPokemon.name) has \(self.pokeMovesArray.count) moves ↓", for: .normal)
        }
        else {
            // change the button's text
            self.pokeMovesViewButton.setTitle("\(self.selectedPokemon.name) has \(self.pokeMovesArray.count) moves ↑", for: .normal)
        }
    }
    
    
    @IBAction func changeSprite(_ sender: Any) {
        // start activity indicator
        pokeImageActivityIndicator.startAnimating()
        
        if self.isShiny == false {
            if self.selectedPokemon.shinySprite! == "error" {
                pokeImageActivityIndicator.stopAnimating()
                let alert = UIAlertController(title: "Not found 😟", message: "\(selectedPokemon.name) does not have a Shiny version.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                changeSpriteLabel.isEnabled = false
                changeSpriteLabel.backgroundColor = UIColor.darkGray
            } else {
                // get and display the shiny sprite from the link
                Alamofire.request(self.selectedPokemon.shinySprite!).responseImage { response in
                    if let img = response.result.value {
                        self.pokeImage.image = img
                    }
                    // stop activity indicator
                    self.pokeImageActivityIndicator.stopAnimating()
                }
                // change the button's background color to default's color mode
                self.changeSpriteLabel.backgroundColor = UIColor.darkGray
                // change the button's text
                self.changeSpriteLabel.setTitle("Show Default", for: .normal)
                // add "Shiny" to the pokemon's name
                self.pokeNameLabel.text = "Shiny \(self.selectedPokemon.name)"
                self.isShiny = true
            }
        } else {
            // get and display the default sprite from the link
            Alamofire.request(selectedPokemon.defaultSprite!).responseImage { response in
                if let img = response.result.value {
                    self.pokeImage.image = img
                }
                // stop activity indicator
                self.pokeImageActivityIndicator.stopAnimating()
            }
             // change the button's background color to shiny's color mode
            self.changeSpriteLabel.backgroundColor = UIColor.orange
            // change the button's text
            self.changeSpriteLabel.setTitle("Show Shiny", for: .normal)
            // sets the pokemon's name back to normal
            self.pokeNameLabel.text = self.selectedPokemon.name
            self.isShiny = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokeMovesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a real cell using the prototype
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "pokeMoveCell" , for: indexPath)
        
        let customSelectedCellColor = UIView()
        // change background color and labels' color to match the app theme
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        if darkSwitch == true {
            cell.textLabel?.textColor = UIColor.white
            // change the selected cell background color
            customSelectedCellColor.backgroundColor = UIColor.darkGray
            cell.selectedBackgroundView = customSelectedCellColor
        }
        else {
            cell.textLabel?.textColor = UIColor.black
            // change the selected cell background color
            customSelectedCellColor.backgroundColor = UIColor.lightGray
            cell.selectedBackgroundView = customSelectedCellColor
        }
        
        // fill the cells with moves
        let pokeMove = pokeMovesArray[indexPath.row]
        cell.textLabel?.text = pokeMove.name
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check if it is the right destination View Controller
        if let detailMoveVC = segue.destination as? MoveInfoViewController {
            // get selected cell
            if let cell = sender as? UITableViewCell {
                // get its index
                let indexPath = pokeMoveTableView.indexPath(for: cell)
                // get pokemon object at that index
                let selectedMove = pokeMovesArray[indexPath!.row]
                // send the pokemon selected to the destination View Controller
                detailMoveVC.selectedMove = selectedMove
            }
        }
    }
}

// set pokeMovesTableView height automatically according to its content
class pokeMovesTableView: UITableView {
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
}
