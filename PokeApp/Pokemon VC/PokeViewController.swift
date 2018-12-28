//
//  PokeViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 16/10/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class PokeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var pokeArray = [Pokemon]()
    var pokeFilteredArray = [Pokemon]()
    var favArray = [Pokemon]()
    let themeDefault = UserDefaults.standard
    
    @IBOutlet weak var pokeTableView: UITableView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.style = .whiteLarge
        
        // setup the search sontroller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search a Pokémon"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        // set the cell height
        self.pokeTableView.rowHeight = 71.0
        
        loadPokemon()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check from if dark theme is enabled
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch == true {
            darkTheme()
            searchController.searchBar.barStyle = .black
            loadingLabel.textColor = UIColor.white
            activityIndicator.color = UIColor.white
            // table view separator color
            pokeTableView.separatorColor = Constants.Colors.gray40
        } else {
            lightTheme()
            searchController.searchBar.barStyle = .default
            loadingLabel.textColor = UIColor.black
            activityIndicator.color = UIColor.black
            // table view separator color
            pokeTableView.separatorColor = UIColor.lightGray
        }
        // update table view UI
        pokeTableView.reloadData()
        
        // auto deselect cell
        if let index = self.pokeTableView.indexPathForSelectedRow {
            self.pokeTableView.deselectRow(at: index, animated: true)
        }
    }
    
    private func loadPokemon() {
        // start activity indicator
        activityIndicator.startAnimating()
        
        Alamofire.request(Constants.PokeApi.pokeApi).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                if let pokemons = jsonDict["results"] as? [[String: Any]] {
                    self.pokeArray = pokemons.map { pokeJson -> Pokemon in
                        return Pokemon(pokeJson: pokeJson)!
                    }                    
                    // tell UITable View to reload UI from the poke array
                    self.pokeTableView.reloadData()
                    
                    self.title = "\(self.pokeArray.count) Pokémon"
                }
                // stop activity indicator
                self.activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.6, animations: {
                    self.loadingLabel.isHidden = true
                })
            }
        }
    }
    
    @IBAction func sortPokemon(_ sender: Any) {
        // setup an action sheet and its title
        let actionSheet = UIAlertController(title: "Choose a way to sort Pokémon", message: nil, preferredStyle: .actionSheet)
        // then we add a cancel button and our sorting options
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Sort by ID number", style: .default) { action in
            // sort pokémon by id number
            self.pokeArray = self.pokeArray.sorted { $0.id < $1.id }
            self.sortButton.title = "Sorting by ID"
            self.pokeTableView.reloadData()
        })
        actionSheet.addAction(UIAlertAction(title: "Sort by ID reversed", style: .default) { action in
            // sort pokémon by id number
            self.pokeArray = self.pokeArray.sorted { $0.id > $1.id }
            self.sortButton.title = "Sorting by ID reversed"
            self.pokeTableView.reloadData()
        })
        actionSheet.addAction(UIAlertAction(title: "Sort A-Z", style: .default) { action in
            // sort pokémon alphabetically
            self.pokeArray = self.pokeArray.sorted { $0.name < $1.name }
            self.sortButton.title = "Sorting A-Z"
            self.pokeTableView.reloadData()
        })
        actionSheet.addAction(UIAlertAction(title: "Sort Z-A", style: .default) { action in
            // sort pokémon "un-alphabetically"
            self.pokeArray = self.pokeArray.sorted { $0.name > $1.name }
            self.sortButton.title = "Sorting Z-A"
            self.pokeTableView.reloadData()
        })
        actionSheet.addAction(UIAlertAction(title: "Sort Randomly 👻", style: .default) { action in
            // sort pokémon randomly
            self.pokeArray = self.pokeArray.shuffled()
            self.sortButton.title = "Sorting Randomly"
            self.pokeTableView.reloadData()
        })
        present(actionSheet, animated: true, completion: nil)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        pokeFilteredArray = pokeArray.filter({(poke : Pokemon) -> Bool in
            return poke.name.lowercased().contains(searchText.lowercased())
        })
        pokeTableView.reloadData()
    }

    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return pokeFilteredArray.count
        }
        return pokeArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a real cell using the prototype
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokeCell" , for: indexPath) as! MainPokeTableViewCell
        
        let customSelectedCellColor = UIView()
        // change background color and labels' color to match the app theme
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        if darkSwitch == true {
            cell.nameLabel.textColor = UIColor.white
            cell.detailLabel.textColor = UIColor.lightGray
            cell.idLabel.textColor = UIColor.lightGray
            cell.backgroundColor = Constants.Colors.gray28
            // change the selected cell background color
            customSelectedCellColor.backgroundColor = UIColor.darkGray
            cell.selectedBackgroundView = customSelectedCellColor
        } else {
            cell.nameLabel.textColor = UIColor.black
            cell.detailLabel.textColor = UIColor.darkGray
            cell.idLabel.textColor = UIColor.darkGray
            cell.backgroundColor = Constants.Colors.light
            // change the selected cell background color
            customSelectedCellColor.backgroundColor = Constants.Colors.light200
            cell.selectedBackgroundView = customSelectedCellColor
        }
        
        // fill the cell
        let poke: Pokemon
        if isFiltering() {
            poke = pokeFilteredArray[indexPath.row]
        } else {
            poke = pokeArray[indexPath.row]
        }
        cell.setPokeCell(poke: poke)
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let pokemon: Pokemon
        if isFiltering() {
            pokemon = pokeFilteredArray[indexPath.row]
        } else {
            pokemon = pokeArray[indexPath.row]
        }
        // get the fav array saved
        if let data = themeDefault.value(forKey:"FavPokemon") as? Data {
            favArray = try! PropertyListDecoder().decode([Pokemon].self, from: data)
        }
        
        let favAction = UIContextualAction(style: .normal, title: "Add to favorite") { (action, view, completion) in
            if self.favArray.contains(where: { $0.name == pokemon.name }) == false {
                // add pokémon to favArray
                self.favArray.append(pokemon)
                // save the array
                self.themeDefault.set(try? PropertyListEncoder().encode(self.favArray), forKey:"FavPokemon")
            } else {
                // finding index using index(where:) method
                if let index = self.favArray.index(where: { $0.name == pokemon.name }) {
                    // removing item
                    self.favArray.remove(at: index)
                    // save the array
                    self.themeDefault.set(try? PropertyListEncoder().encode(self.favArray), forKey:"FavPokemon")
                }
            }
            completion(true)
        }
        
        if self.favArray.contains(where: { $0.name == pokemon.name }) == false {
            // set favorite icon when pokemon is not favorite
            favAction.image = UIImage(named: "Favorite")!
            // set the background to blue when pokemon is not favorite
            favAction.backgroundColor = Constants.Colors.blue
        } else {
            // set favorited icon when pokemon is favorite
            favAction.image = UIImage(named: "Favorited")!
            // set the background to orange when pokemon is favorite
            favAction.backgroundColor = .darkGray
        }
        
        return UISwipeActionsConfiguration(actions: [favAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // return an empty array to disable trailing swipe actions
        return UISwipeActionsConfiguration(actions: [])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check if it is the right destination View Controller
        if let detailPokemon = segue.destination as? PokeInfoController {
            // get selected cell
            if let cell = sender as? UITableViewCell {
                // get its index
                let indexPath = pokeTableView.indexPath(for: cell)
                // get pokemon object at that index
                let selectedPokemon: Pokemon
                if isFiltering() {
                    selectedPokemon = pokeFilteredArray[indexPath!.row]
                } else {
                    selectedPokemon = pokeArray[indexPath!.row]
                }
                // send the pokemon selected to the destination View Controller
                detailPokemon.selectedPokemon = selectedPokemon
            }
        }
    }
}

class MainPokeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var spriteImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    func setPokeCell(poke: Pokemon) {
        // setting name label with pokemon name and id label with pokemon id
        nameLabel.text = poke.name
        idLabel.text = "\(poke.id)"
        // adjusting pokémon name if too long to fit
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.lineBreakMode = .byClipping
        
        // setting detail label with types
        Alamofire.request(poke.url).responseJSON { response in
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

                    // display the types in the View Controller
                    self.detailLabel.text = selectedPokemonTypes
                }
            }
        }
        
        // setting image
        let placeholderImage: UIImage = UIImage(named: "Placeholder")!
        spriteImage.image = placeholderImage
        
        let frontSprite = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(poke.id).png"
        // get and display the sprite from the image link + the pokemon id
        Alamofire.request(frontSprite).responseImage { response in
            if let img = response.result.value {
                self.spriteImage.image = img
            }
        }
    }
}
