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
    
    var itemsArray = [Items]()
    var itemsFilteredArray = [Items]()
    
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var itemActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search an item"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // set the cell height
        self.itemTableView.rowHeight = 71.0
        
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
            itemActivityIndicator.color = UIColor.white
            // table view separator color
            itemTableView.separatorColor = Constants.Colors.gray40
        } else {
            lightTheme()
            searchController.searchBar.barStyle = .default
            loadingLabel.textColor = UIColor.black
            itemActivityIndicator.color = UIColor.black
            // table view separator color
            itemTableView.separatorColor = UIColor.lightGray
        }
        // update table view UI
        itemTableView.reloadData()
        
        // auto deselect cell
        if let index = self.itemTableView.indexPathForSelectedRow {
            self.itemTableView.deselectRow(at: index, animated: true)
        }
    }
    
    private func loadPokemon() {
        // start activity indicator
        itemActivityIndicator.startAnimating()
        
        Alamofire.request(Constants.ItemApi.itemApi).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                if let items = jsonDict["results"] as? [[String: Any]] {
                    self.itemsArray = items.map { pokeJson -> Items in
                        return Items(pokeJson: pokeJson)!
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
    
    @IBAction func sortItems(_ sender: Any) {
        // setup an action sheet and its title
        let actionSheet = UIAlertController(title: "Choose a way to sort items", message: nil, preferredStyle: .actionSheet)
        // then we add a cancel button and our sorting options
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Sort by ID number", style: .default) { action in
            // sort items by id number
            self.itemsArray = self.itemsArray.sorted { $0.id < $1.id }
            self.sortButton.title = "Sorting by ID"
            self.itemTableView.reloadData()
        })
        actionSheet.addAction(UIAlertAction(title: "Sort by ID reversed", style: .default) { action in
            // sort items by id number
            self.itemsArray = self.itemsArray.sorted { $0.id > $1.id }
            self.sortButton.title = "Sorting by ID reversed"
            self.itemTableView.reloadData()
        })
        actionSheet.addAction(UIAlertAction(title: "Sort A-Z", style: .default) { action in
            // sort items alphabetically
            self.itemsArray = self.itemsArray.sorted { $0.name < $1.name }
            self.sortButton.title = "Sorting A-Z"
            self.itemTableView.reloadData()
        })
        actionSheet.addAction(UIAlertAction(title: "Sort Z-A", style: .default) { action in
            // sort items "un-alphabetically"
            self.itemsArray = self.itemsArray.sorted { $0.name > $1.name }
            self.sortButton.title = "Sorting Z-A"
            self.itemTableView.reloadData()
        })
        actionSheet.addAction(UIAlertAction(title: "Sort Randomly 👻", style: .default) { action in
            // sort items randomly
            self.itemsArray = self.itemsArray.shuffled()
            self.sortButton.title = "Sorting Randomly"
            self.itemTableView.reloadData()
        })
        present(actionSheet, animated: true, completion: nil)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        itemsFilteredArray = itemsArray.filter({(items : Items) -> Bool in
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
        
        let customSelectedCellColor = UIView()
        // change background color and labels' color to match the app theme
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        if darkSwitch == true {
            cell.nameLabel.textColor = UIColor.white
            cell.detailLabel.textColor = UIColor.lightGray
            cell.backgroundColor = Constants.Colors.gray28
            // change the selected cell background color
            customSelectedCellColor.backgroundColor = UIColor.darkGray
            cell.selectedBackgroundView = customSelectedCellColor
        }
        else {
            cell.nameLabel.textColor = UIColor.black
            cell.detailLabel.textColor = UIColor.darkGray
            cell.backgroundColor = Constants.Colors.light
            // change the selected cell background color
            customSelectedCellColor.backgroundColor = Constants.Colors.light200
            cell.selectedBackgroundView = customSelectedCellColor
        }
        
        // fill the cell
        let items: Items
        if isFiltering() {
            items = itemsFilteredArray[indexPath.row]
        }
        else {
            items = itemsArray[indexPath.row]
        }
        cell.setItemCell(items: items)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check if it is the right destination View Controller
        if let detailItem = segue.destination as? ItemInfoViewController {
            // get selected cell
            if let cell = sender as? UITableViewCell {
                // get its index
                let indexPath = itemTableView.indexPath(for: cell)
                // get item object at that index
                let selectedItem: Items
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
    
    func setItemCell(items: Items) {
        nameLabel.text = items.name
        
        // setting detail label with cost
        Alamofire.request(items.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                // get the item's cost
                guard let itemCost = jsonDict["cost"] as? Int
                    else {
                        return
                }
                self.detailLabel.text = "₽\(itemCost)"
            }
        }

        // setting image
        let placeholderImage = UIImage(named: "Placeholder")!
        var itemName = items.name.lowercased().replacingOccurrences(of: " ", with: "-")
        if itemName.contains("tm") {
            itemName = itemName.replacingOccurrences(of: itemName, with: "tm-normal")
        }
        // create sprite link with item name
        let sprite = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/\(itemName).png")!
        // display image or placeholder
        spriteImage.af_setImage(withURL: sprite, placeholderImage: placeholderImage)
    }
}

