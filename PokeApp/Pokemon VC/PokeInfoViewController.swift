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

class PokeInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedPokemon: Pokemon!
    var pokeMovesArray = [Moves]()
    var isShiny: Bool = false
    var favArray = [Pokemon]()
    
    // setting placeholder image
    let placeholderImage = UIImage(named: "Placeholder")!
    
    var activityIndicator: UIActivityIndicatorView!
    var blurView: UIView!
    var blurEffectView: UIVisualEffectView!
    var favMessage: UILabel!
    let themeDefault = UserDefaults.standard

    @IBOutlet weak var favButton: UIBarButtonItem!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display pokemon name in the Navigation Bar title and a label
        title = selectedPokemon.name
        pokeNameLabel.text = selectedPokemon.name
        // adjusts font size of the name in the label to fit in the view if too long
        pokeNameLabel.adjustsFontSizeToFitWidth = true
        pokeNameLabel.lineBreakMode = .byClipping
        
        // set background color of the button to orange
        changeSpriteLabel.backgroundColor = UIColor.orange
        
        // set round top corners to something
        // bug: element's width do not change when holding device in landscape mode
        // self.add something here.roundCorners([.topLeft, .topRight], radius: 4)
        
        // hide pokemon moves table view
        pokeMoveTableView.isHidden = true
        
        pokeImageActivityIndicator.stopAnimating()
        
        loadPokemonDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check if pokemon is favorite
        if let data = themeDefault.value(forKey:"FavPokemon") as? Data {
            favArray = try! PropertyListDecoder().decode([Pokemon].self, from: data)
        }
        if favArray.contains(where: { $0.name == selectedPokemon.name }) {
            favButton.title = "Unfav"
            favButton.image = UIImage(named: "Favorited")!
        } else {
            favButton.title = "Fav"
            favButton.image = UIImage(named: "Favorite")!
        }
        
        // check from if dark theme is enabled
        let darkSwitch = themeDefault.bool(forKey: "themeDefault")
        
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch {
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
        pokeImageActivityIndicator.color = UIColor.white
        activityIndicator.color = UIColor.white
        
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
        pokeImageActivityIndicator.color = UIColor.black
        activityIndicator.color = UIColor.black

        // table view separator and background color
        pokeMoveTableView.separatorColor = UIColor.lightGray
        pokeMoveTableView.backgroundColor = UIColor.white
    }
    
    func setLoadingView() {
        // create blur overlay
        blurView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.addSubview(blurView)
        
        let blurEffect: UIBlurEffect!
        
        // get theme mode
        let darkSwitch = themeDefault.bool(forKey: "themeDefault")
        
        if !UIAccessibility.isReduceTransparencyEnabled {
            blurView.backgroundColor = .clear
            if darkSwitch {
                blurEffect = UIBlurEffect(style: .dark)
            } else {
                blurEffect = UIBlurEffect(style: .light)
            }
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            // always fill the view
            blurEffectView.frame = blurView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurView.addSubview(blurEffectView)
        } else {
            if darkSwitch {
                blurView.backgroundColor = Constants.Colors.gray28
            } else {
                blurView.backgroundColor = .white
            }
        }
        
        // create activity indicator
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        // start activity indicator
        activityIndicator.startAnimating()
        // show activity indicator
        view.addSubview(activityIndicator)
    }
    
    private func loadPokemonDetails() {
        setLoadingView()
        
        // get the detail dictionary of the pokemon from the url of the pokemon
        Alamofire.request(selectedPokemon.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                
                // set the sprites, types, height, weight and abilities from jsonDict for the selected pokemon
                self.selectedPokemon.setSprites(jsonObject: jsonDict)
                self.selectedPokemon.setTypes(jsonObject: jsonDict)
                self.selectedPokemon.setPhysicalAttributes(jsonObject: jsonDict)
                self.selectedPokemon.setAbilities(jsonObject: jsonDict)
                
                // get sprite link
                let spriteURL = URL(string: self.selectedPokemon.defaultSprite!)!
                // display image or placeholder
                self.pokeImage.af_setImage(withURL: spriteURL, placeholderImage: self.placeholderImage)

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
                })
            }
        }
    }
    
    func typeTypes() -> String {
        // writes Types when pokemon has several types and Type when it has only one
        if self.selectedPokemon.typeOrTypes! > 1 {
            let typeOrTypes = "Types: %@"
            return typeOrTypes
        } else {
            let typeOrTypes = "Type: %@"
            return typeOrTypes
        }
    }
    
    @IBAction func addToFav(_ sender: Any) {
        // get the fav array saved
        if let data = themeDefault.value(forKey:"FavPokemon") as? Data {
            favArray = try! PropertyListDecoder().decode([Pokemon].self, from: data)
        }
        
        if favArray.contains(where: { $0.name == selectedPokemon.name }) == false {
            // change button's title
            favButton.title = "Unfav"
            favButton.image = UIImage(named: "Favorited")!
            // add pokémon to favArray
            favArray.append(selectedPokemon)
            // save the array
            themeDefault.set(try? PropertyListEncoder().encode(favArray), forKey:"FavPokemon")
            // show message
            showAlert()
        } else {
            // change button's title
            favButton.title = "Fav"
            favButton.image = UIImage(named: "Favorite")!
            // finding index using index(where:) method
            if let index = self.favArray.firstIndex(where: { $0.name == selectedPokemon.name }) {
                // removing item
                self.favArray.remove(at: index)
                // save the array
                themeDefault.set(try? PropertyListEncoder().encode(favArray), forKey:"FavPokemon")
            }
        }
    }
    
    func showAlert() {
        // show blur view
        UIView.animate(withDuration: 0.2, animations: {
            self.blurView.alpha = 1.0
        })
        
        // create a label with the message
        favMessage = UILabel(frame: CGRect(x: UIScreen.main.bounds.width/2 - 120, y: UIScreen.main.bounds.height/2 - 40, width: 240, height: 80))
        let attributedString = NSMutableAttributedString(string: "\(selectedPokemon.name) has been added to your favorites!")
        // create instance of NSMutableParagraphStyle
        let paragraphStyle = NSMutableParagraphStyle()
        // set line spacing in points
        paragraphStyle.lineSpacing = 8
        // apply attribute to string
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        favMessage.attributedText = attributedString
        favMessage.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        // set text color
        let darkSwitch = themeDefault.bool(forKey: "themeDefault")
        if darkSwitch {
            favMessage.textColor = UIColor.white
        } else {
            favMessage.textColor = UIColor.black
        }
        
        // set text behaviour
        favMessage.lineBreakMode = .byWordWrapping
        favMessage.numberOfLines = 0
        favMessage.textAlignment = .center
        
        // show on screen
        blurView.addSubview(favMessage)
        
        // set the timer
        Timer.scheduledTimer(timeInterval: 1.6, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
    }
    
    @objc func dismissAlert(){
        // dismiss the view
        if blurView != nil {
            UIView.animate(withDuration: 0.6, animations: {
                self.blurView.alpha = 0.0
            })
            favMessage.removeFromSuperview()
        }
    }
    
    @IBAction func pokeMovesButton(_ sender: Any) {
        UIStackView.animateVisibilityOfViews([pokeMoveTableView], hidden: !pokeMoveTableView.isHidden)
        if pokeMoveTableView.isHidden {
            // change the button's text
            self.pokeMovesViewButton.setTitle("\(self.selectedPokemon.name) has \(self.pokeMovesArray.count) moves ↓", for: .normal)
        } else {
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
                let alert = UIAlertController(title: "Not found 😟", message: "\(selectedPokemon.name) does not have a Shiny sprite.", preferredStyle: .alert)
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
            // get shiny sprite link
            let spriteURL = URL(string: self.selectedPokemon.defaultSprite!)!
            // display image or placeholder
            self.pokeImage.af_setImage(withURL: spriteURL, placeholderImage: placeholderImage)
            
            // stop activity indicator
            self.pokeImageActivityIndicator.stopAnimating()
            
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
        if darkSwitch {
            cell.textLabel?.textColor = UIColor.white
            // change the selected cell background color
            customSelectedCellColor.backgroundColor = UIColor.darkGray
            cell.selectedBackgroundView = customSelectedCellColor
        } else {
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
