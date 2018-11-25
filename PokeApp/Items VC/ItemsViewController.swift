//
//  ItemsViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 04/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var itemsArray = [Pokemon]()
    var itemsFilteredArray = [Pokemon]()
    
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var itemActivityIndicator: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .black
        searchController.searchBar.placeholder = "Search an item"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // set the cell height
        self.itemTableView.rowHeight = 71.0
        
        loadPokemon()
    }
    
    private func loadPokemon() {
        // start activity indicator
        itemActivityIndicator.startAnimating()
        
        Alamofire.request(Constants.ItemApi.itemApi).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                if let items = jsonDict["results"] as? [[String: Any]] {
                    self.itemsArray = items.map { pokeJson -> Pokemon in
                        return Pokemon(pokeJson: pokeJson)!
                    }
                    
                    // tell UITable View to reload UI from the items array
                    self.itemTableView.reloadData()
                    
                    self.title = "\(self.itemsArray.count) Items"
                }
                // stop activity indicator
                self.itemActivityIndicator.stopAnimating()
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
        itemsFilteredArray = itemsArray.filter({(items : Pokemon) -> Bool in
            return items.name.lowercased().contains(searchText.lowercased())
        })
        itemTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return itemsFilteredArray.count
        }
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a real cell using the prototype
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell" , for: indexPath) as! MainItemTableViewCell
        
        // change the selected cell background color
        let customSelectedCellColor = UIView()
        customSelectedCellColor.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = customSelectedCellColor
        
        // fill the cell
        let items: Pokemon
        if isFiltering() {
            items = itemsFilteredArray[indexPath.row]
        }
        else {
            items = itemsArray[indexPath.row]
        }
        cell.setItemCell(items: items)
        cell.setItemImageCell(items: items)
        return cell
    }
    
    // auto deselect cell
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.itemTableView.indexPathForSelectedRow {
            self.itemTableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check if it is the right destination View Controller
        if let detailItem = segue.destination as? ItemInfoViewController {
            // get selected cell
            if let cell = sender as? UITableViewCell {
                // get its index
                let indexPath = itemTableView.indexPath(for: cell)
                // get item object at that index
                let selectedItem: Pokemon
                if isFiltering() {
                    selectedItem = itemsFilteredArray[indexPath!.row]
                }
                else {
                    selectedItem = itemsArray[indexPath!.row]
                }
                // send the selected item to the destination View Controller
                detailItem.selectedItem = selectedItem
            }
        }
    }
    
}

class MainItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var spriteImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    func setItemCell(items: Pokemon) {
        nameLabel.text = items.name
        detailLabel.text = items.url
    }
    
    func setSearchItemCell(itemSearch: Pokemon) {
        nameLabel.text = itemSearch.name
        detailLabel.text = itemSearch.url
    }
    
    func setItemImageCell(items: Pokemon) {
        let placeholderImage: UIImage = UIImage(named: "Placeholder")!
        spriteImage.image = placeholderImage
        
        Alamofire.request(items.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                // get the sprites dictionary
                guard let itemSprite = jsonDict["sprites"] as? [String: String],
                    // get one sprite link from the dictionary
                    let defaultSprite = itemSprite["default"]
                    else {
                        return
                }
                
                // get and display the sprite from the link
                Alamofire.request(defaultSprite).responseImage { response in
                    if let img = response.result.value {
                        self.spriteImage.image = img
                    }
                }
            }
        }
    }
}

