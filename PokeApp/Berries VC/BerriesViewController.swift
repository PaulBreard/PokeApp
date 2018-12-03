//
//  BerriesViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 04/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class BerriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var berriesArray = [Items]()
    var berriesFilteredArray = [Items]()
    var isSortedAZ: Bool = false
    
    @IBOutlet weak var berryTableView: UITableView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var berryActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search a berry"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // set the cell height
        self.berryTableView.rowHeight = 71.0
        
        loadBerries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check from if dark theme is enabled
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch == true {
            darkTheme()
            searchController.searchBar.barStyle = .black
            loadingLabel.textColor = UIColor.white
            berryActivityIndicator.color = UIColor.white
            // table view separator color
            berryTableView.separatorColor = Constants.Colors.gray40
        } else {
            lightTheme()
            searchController.searchBar.barStyle = .default
            loadingLabel.textColor = UIColor.black
            berryActivityIndicator.color = UIColor.black
            // table view separator color
            berryTableView.separatorColor = UIColor.lightGray
        }
        // update table view UI
        berryTableView.reloadData()
        
        // auto deselect cell
        if let index = self.berryTableView.indexPathForSelectedRow {
            self.berryTableView.deselectRow(at: index, animated: true)
        }
    }
    
    private func loadBerries() {
        // start activity indicator
        berryActivityIndicator.startAnimating()
        
        Alamofire.request(Constants.BerryApi.berryApi).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                if let berries = jsonDict["results"] as? [[String: Any]] {
                    self.berriesArray = berries.map { pokeJson -> Items in
                        return Items(pokeJson: pokeJson)!
                    }
                    // tell UITable View to reload UI from the berry array
                    self.berryTableView.reloadData()
                    
                    self.title = "\(self.berriesArray.count) Berries"
                }
                // stop activity indicator
                self.berryActivityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.6, animations: {
                    self.loadingLabel.isHidden = true
                })
            }
        }
    }
    
    @IBAction func sortBerries(_ sender: Any) {
        if isSortedAZ == false {
            // sort pokémon alphabetically
            berriesArray = berriesArray.sorted { $0.name < $1.name }
            sortButton.title = "Sort by ID"
            isSortedAZ = true
        } else {
            berriesArray = berriesArray.sorted { $0.id < $1.id }
            sortButton.title = "Sort A-Z"
            isSortedAZ = false
        }
        berryTableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        berriesFilteredArray = berriesArray.filter({(berry : Items) -> Bool in
            return berry.name.lowercased().contains(searchText.lowercased())
        })
        berryTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return berriesFilteredArray.count
        }
        return berriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a real cell using the prototype
        let cell = tableView.dequeueReusableCell(withIdentifier: "berryCell" , for: indexPath) as! MainBerryTableViewCell
        
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
            customSelectedCellColor.backgroundColor = UIColor.lightGray
            cell.selectedBackgroundView = customSelectedCellColor
        }
        
        // fill the cell
        let berry: Items
        if isFiltering() {
            berry = berriesFilteredArray[indexPath.row]
        }
        else {
            berry = berriesArray[indexPath.row]
        }
        cell.setBerryCell(berry: berry)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check if it is the right destination View Controller
        if let detailBerry = segue.destination as? BerryInfoViewController {
            // get selected cell
            if let cell = sender as? UITableViewCell {
                // get its index
                let indexPath = berryTableView.indexPath(for: cell)
                // get berry object at that index
                let selectedBerry: Items
                if isFiltering() {
                    selectedBerry = berriesFilteredArray[indexPath!.row]
                }
                else {
                    selectedBerry = berriesArray[indexPath!.row]
                }
                // send the berry selected to the destination View Controller
                detailBerry.selectedBerry = selectedBerry
            }
        }
    }
    
}

class MainBerryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var spriteImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    func setBerryCell(berry: Items) {
        nameLabel.text = berry.name
        
        // setting detail label with firmness
        Alamofire.request(berry.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                // get the berry's firmness
                guard let berryFirmnessArray = jsonDict["firmness"] as? [String: String],
                    let berryFirmness = berryFirmnessArray["name"]
                    else {
                        return
                }
                self.detailLabel.text = berryFirmness.capitalized.replacingOccurrences(of: "-", with: " ")
            }
        }
        
        // add berry name in sprite url
        let berryName = berry.name.lowercased().replacingOccurrences(of: " ", with: "-")
        let sprite = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/\(berryName)-berry.png"
        // get and display the sprite from the image link
        Alamofire.request(sprite).responseImage { response in
            if let img = response.result.value {
                self.spriteImage.image = img
            }
        }
    }
}
