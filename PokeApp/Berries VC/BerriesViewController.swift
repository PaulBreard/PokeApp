//
//  BerriesViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 04/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Alamofire

class BerriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var berriesArray = [Pokemon]()
    var berriesFilteredArray = [Pokemon]()
    
    @IBOutlet weak var berryTableView: UITableView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var berryActivityIndicator: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .black
        searchController.searchBar.placeholder = "Search a berry"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // set the cell height
        self.berryTableView.rowHeight = 71.0
        
        loadBerries()
    }
    
    private func loadBerries() {
        // start activity indicator
        berryActivityIndicator.startAnimating()
        
        Alamofire.request(Constants.BerryApi.berryApi).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                if let berries = jsonDict["results"] as? [[String: Any]] {
                    self.berriesArray = berries.map { pokeJson -> Pokemon in
                        return Pokemon(pokeJson: pokeJson)!
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
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        berriesFilteredArray = berriesArray.filter({(berry : Pokemon) -> Bool in
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
        
        // change the selected cell background color
        let customSelectedCellColor = UIView()
        customSelectedCellColor.backgroundColor = UIColor.darkGray
        cell.selectedBackgroundView = customSelectedCellColor
        
        // fill the cell
        let berry: Pokemon
        if isFiltering() {
            berry = berriesFilteredArray[indexPath.row]
        }
        else {
            berry = berriesArray[indexPath.row]
        }
        cell.setBerryCell(berry: berry)
        return cell
    }
    
    // auto deselect cell
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.berryTableView.indexPathForSelectedRow {
            self.berryTableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check if it is the right destination View Controller
        if let detailBerry = segue.destination as? BerryInfoViewController {
            // get selected cell
            if let cell = sender as? UITableViewCell {
                // get its index
                let indexPath = berryTableView.indexPath(for: cell)
                // get berry object at that index
                let selectedBerry: Pokemon
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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    func setBerryCell(berry: Pokemon) {
        nameLabel.text = berry.name
        detailLabel.text = berry.url
    }
    
    func setSearchBerryCell(berrySearch: Pokemon) {
        nameLabel.text = berrySearch.name
        detailLabel.text = berrySearch.url
    }
}
