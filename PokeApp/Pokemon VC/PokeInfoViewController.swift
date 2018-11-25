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
    var pokeTypesArray = [PokemonTypes]()
    var pokeAbilitiesArray = [PokemonAbilities]()
    var pokeMovesArray = [PokemonMoves]()
    var isShiny: Bool = false

    @IBOutlet weak var pokeNameLabel: UILabel!
    @IBOutlet weak var pokeTypeLabel: UILabel!
    @IBOutlet weak var typeOrTypesLabel: UILabel!
    @IBOutlet weak var pokeImage: UIImageView!
    @IBOutlet weak var blurImageView: UIView!
    @IBOutlet weak var pokeImageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pokeHeightLabel: UILabel!
    @IBOutlet weak var pokeWeightLabel: UILabel!
    @IBOutlet weak var pokeAbilitiesLabel: UILabel!
    @IBOutlet weak var changeSpriteLabel: UIButton!
    @IBOutlet weak var pokeMovesViewButton: UIButton!
    @IBOutlet weak var pokeMoveTableView: UITableView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var pokeInfoActivityIndicator: UIActivityIndicatorView!
    
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
//        self.add something here.roundCorners([.topLeft, .topRight], radius: 4)
        
        // overlay on pokemon image
        self.blurImageView.alpha = 0.0
        
        // hide pokemon moves table view
        self.pokeMoveTableView.isHidden = true
        
        loadPokemonDetails()
    }
    
    private func loadPokemonDetails() {
        // start activity indicator
        pokeInfoActivityIndicator.startAnimating()
        pokeImageActivityIndicator.startAnimating()
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

        // get the detail dictionary of the pokemon from the url of the pokemon
        Alamofire.request(selectedPokemon.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                
                // get the pokemon types array
                guard let pokeTypesArray = jsonDict["types"] as? [[String: Any]]
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
                    
                    // writes Types when pokemon has several types and Type when it has only one
                    if arrayOfPokeTypes.count > 1 {
                        self.typeOrTypesLabel.text = "Types:"
                    }
                    else {
                        self.typeOrTypesLabel.text = "Type:"
                    }
                    
                    // display the types in the View Controller
                    self.pokeTypeLabel.text = selectedPokemonTypes
                    
                    // display results in the console
                    print("Type:", selectedPokemonTypes)
                }
                
                // get the pokemon abilities array
                guard let pokeAbilitiesArray = jsonDict["abilities"] as? [[String: Any]]
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
                    let selectedPokemonAbilities = arrayOfPokeAbilities.joined(separator: ", ")
                    
                    // display the abilities in the View Controller
                    self.pokeAbilitiesLabel.text = selectedPokemonAbilities.replacingOccurrences(of: "-", with: " ")
                    self.pokeAbilitiesLabel.lineBreakMode = .byWordWrapping
                    self.pokeAbilitiesLabel.numberOfLines = 0
                    
                    // display results in the console
                    print("Abilities:", selectedPokemonAbilities)
                    
                    // stop activity indicator
                    self.pokeInfoActivityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.6, animations: {
                        self.blurView.alpha = 0.0
                        self.loadingLabel.isHidden = true
                    })
                }
                
                // get the sprites dictionary
                guard let pokeSprite = jsonDict["sprites"] as? [String: String],
                    // get one sprite link from the dictionary
                    let frontSprite = pokeSprite["front_default"]
                else {
                    return
                }
                // display results in the console
                print("Sprite URL:", frontSprite)
                
                // get and display the sprite from the link
                Alamofire.request(frontSprite).responseImage { response in
                    if let img = response.result.value {
                        self.pokeImage.image = img
                    }
                    // stop activity indicator
                    self.pokeImageActivityIndicator.stopAnimating()
                }
                
                // get the height then the weight
                guard let pokeHeight = jsonDict["height"] as? Double,
                    let pokeWeight = jsonDict["weight"] as? Double
                else {
                    return
                }
                // display results in the console
                print("Height:", pokeHeight)
                print("Weight:", pokeWeight)
                
                // display the pokemon height and weight divided by 10 to obtain correct values
                self.pokeHeightLabel.text = "\(pokeHeight/10) m"
                self.pokeWeightLabel.text = "\(pokeWeight/10) kg"
            }
        }
        
        Alamofire.request(selectedPokemon.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                if let pokemons = jsonDict["moves"] as? [[String: Any]] {
                    self.pokeMovesArray = pokemons.map { pokeJson -> PokemonMoves in
                        return PokemonMoves(pokeJson: pokeJson)!
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
            }
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
        // blur overlay while loading image
        if !UIAccessibility.isReduceTransparencyEnabled {
            self.blurImageView.backgroundColor = .clear
            self.blurImageView.alpha = 1.0
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.blurImageView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blurImageView.addSubview(blurEffectView)
        } else {
            self.blurImageView.backgroundColor = .black
        }
        
        // get the detail dictionary of the pokemon from the url of the pokemon
        Alamofire.request(selectedPokemon.url).responseJSON { response in
            guard let jsonDict = response.result.value as? [String: Any] else {
                return
            }
            // get the sprites dictionary
            guard let pokeSprite = jsonDict["sprites"] as? [String: String],
                // get the default sprite's link from the dictionary
                let frontSprite = pokeSprite["front_default"],
                // get the shiny sprite's link from the dictionary
                let frontShinySprite = pokeSprite["front_shiny"]
            else {
                return
            }
            if self.isShiny == false {
                // get and display the shiny sprite from the link
                Alamofire.request(frontShinySprite).responseImage { response in
                    if let img = response.result.value {
                        self.pokeImage.image = img
                    }
                    // stop activity indicator
                    self.pokeImageActivityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.6, animations: {
                        self.blurImageView.alpha = 0.0
                    })
                }
                // change the button's background color to default's color mode
                self.changeSpriteLabel.backgroundColor = UIColor.darkGray
                // change the button's text
                self.changeSpriteLabel.setTitle("Show Default", for: .normal)
                // add "Shiny" to the pokemon's name
                self.pokeNameLabel.text = "Shiny \(self.selectedPokemon.name)"
                self.isShiny = true
                
            } else {
                // get and display the default sprite from the link
                Alamofire.request(frontSprite).responseImage { response in
                    if let img = response.result.value {
                        self.pokeImage.image = img
                    }
                    // stop activity indicator
                    self.pokeImageActivityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.6, animations: {
                        self.blurImageView.alpha = 0.0
                    })
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
    }
    
    // Table View of Moves
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokeMovesArray.count
    }
    
    // Table View of Moves
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a real cell using the prototype
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "pokeMoveCell" , for: indexPath)
        
        // change the selected cell background color
        let customSelectedCellColor = UIView()
        customSelectedCellColor.backgroundColor = UIColor.lightGray
        cell.selectedBackgroundView = customSelectedCellColor
        
        // fill the cells with moves
        let pokeMove = pokeMovesArray[indexPath.row]
        cell.textLabel?.text = pokeMove.moveName
        
        return cell
    }
    
    // auto deselect cells
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.pokeMoveTableView.indexPathForSelectedRow {
            self.pokeMoveTableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check if it is the right destination View Controller
        if let detailMoveVC = segue.destination as? PokeMoveViewController {
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
