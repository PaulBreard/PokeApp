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
    
    @IBOutlet weak var pokeTableView: UITableView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var pokeActivityIndicator: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .black
        searchController.searchBar.placeholder = "Search a Pokémon"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // set the cell height
        self.pokeTableView.rowHeight = 71.0
        
        loadPokemon()
    }
    
    private func loadPokemon() {
        // start activity indicator
        pokeActivityIndicator.startAnimating()
        
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
                self.pokeActivityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.6, animations: {
                    self.loadingLabel.isHidden = true
                })
            }
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        pokeFilteredArray = pokeArray.filter({(poke : Pokemon) -> Bool in
            return poke.name.lowercased().contains(searchText.lowercased())
        })
        pokeTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
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
        
        // change the selected cell background color
        let customSelectedCellColor = UIView()
        customSelectedCellColor.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = customSelectedCellColor
        
        // fill the cell
        let poke: Pokemon
        if isFiltering() {
            poke = pokeFilteredArray[indexPath.row]
        }
        else {
            poke = pokeArray[indexPath.row]
        }
        cell.setPokeCell(poke: poke)
        cell.setPokeImageCell(poke: poke)
        return cell
    }
    
    // auto deselect cell
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.pokeTableView.indexPathForSelectedRow {
            self.pokeTableView.deselectRow(at: index, animated: true)
        }
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
                }
                else {
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
    
    func setPokeCell(poke: Pokemon) {
        nameLabel.text = poke.name
        detailLabel.text = poke.url
    }
    
    func setSearchPokeCell(pokeSearch: Pokemon) {
        nameLabel.text = pokeSearch.name
        detailLabel.text = pokeSearch.url
    }
    
    func setPokeImageCell(poke: Pokemon) {
        let placeholderImage: UIImage = UIImage(named: "Placeholder")!
        spriteImage.image = placeholderImage
        
        Alamofire.request(poke.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                // get the sprites dictionary
                guard let pokeSprite = jsonDict["sprites"] as? [String: String],
                    // get one sprite link from the dictionary
                    let frontSprite = pokeSprite["front_default"]
                    else {
                        return
                }
                
                // get and display the sprite from the link
                Alamofire.request(frontSprite).responseImage { response in
                    if let img = response.result.value {
                        self.spriteImage.image = img
                    }
                }
            }
        }
    }
}
