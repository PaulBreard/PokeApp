//
//  MovesViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 03/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Alamofire

class MovesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var movesArray = [Moves]()
    var movesFilteredArray = [Moves]()
    
    @IBOutlet weak var moveTableView: UITableView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var moveActivityIndicator: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search a move"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // set the cell height
        self.moveTableView.rowHeight = 71.0
        
        loadMoves()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check from if dark theme is enabled
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch == true {
            darkTheme()
            searchController.searchBar.barStyle = .black
            loadingLabel.textColor = UIColor.white
            moveActivityIndicator.color = UIColor.white
            // table view separator color
            moveTableView.separatorColor = UIColor.darkGray
        } else {
            lightTheme()
            searchController.searchBar.barStyle = .default
            loadingLabel.textColor = UIColor.black
            moveActivityIndicator.color = UIColor.black
            // table view separator color
            moveTableView.separatorColor = UIColor.lightGray
        }
        
        // auto deselect cell
        if let index = self.moveTableView.indexPathForSelectedRow {
            self.moveTableView.deselectRow(at: index, animated: true)
        }
    }
    
    private func loadMoves() {
        // start activity indicator
        moveActivityIndicator.startAnimating()
        
        Alamofire.request(Constants.MoveApi.moveApi).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                if let moves = jsonDict["results"] as? [[String: Any]] {
                    self.movesArray = moves.map { pokeJson -> Moves in
                        return Moves(pokeJson: pokeJson)!
                    }
                    // tell UITable View to reload UI from the move array
                    self.moveTableView.reloadData()
                    
                    self.title = "\(self.movesArray.count) Moves"
                }
                // stop activity indicator
                self.moveActivityIndicator.stopAnimating()
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
        movesFilteredArray = movesArray.filter({(move : Moves) -> Bool in
            return move.name.lowercased().contains(searchText.lowercased())
        })
        moveTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return movesFilteredArray.count
        }
        return movesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a real cell using the prototype
        let cell = tableView.dequeueReusableCell(withIdentifier: "moveCell" , for: indexPath) as! MainMoveTableViewCell
        
        let customSelectedCellColor = UIView()
        // change background color and labels' color to match the app theme
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        if darkSwitch == true {
            cell.nameLabel.textColor = UIColor.white
            cell.detailLabel.textColor = UIColor.lightGray
            // change the selected cell background color
            customSelectedCellColor.backgroundColor = UIColor.darkGray
            cell.selectedBackgroundView = customSelectedCellColor
        }
        else {
            cell.nameLabel.textColor = UIColor.black
            cell.detailLabel.textColor = UIColor.darkGray
            // change the selected cell background color
            customSelectedCellColor.backgroundColor = UIColor.lightGray
            cell.selectedBackgroundView = customSelectedCellColor
        }
        
        // fill the cell
        let move: Moves
        if isFiltering() {
            move = movesFilteredArray[indexPath.row]
        }
        else {
            move = movesArray[indexPath.row]
        }
        cell.setMoveCell(move: move)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check if it is the right destination View Controller
        if let detailMove = segue.destination as? MoveInfoViewController {
            // get selected cell
            if let cell = sender as? UITableViewCell {
                // get its index
                let indexPath = moveTableView.indexPath(for: cell)
                // get move object at that index
                let selectedMove: Moves
                if isFiltering() {
                    selectedMove = movesFilteredArray[indexPath!.row]
                }
                else {
                    selectedMove = movesArray[indexPath!.row]
                }
                // send the move selected to the destination View Controller
                detailMove.selectedMove = selectedMove
            }
        }
    }
    
}

class MainMoveTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    func setMoveCell(move: Moves) {
        nameLabel.text = move.name
        detailLabel.text = move.url
    }
    
    func setSearchMoveCell(moveSearch: Moves) {
        nameLabel.text = moveSearch.name
        detailLabel.text = moveSearch.url
    }
}
