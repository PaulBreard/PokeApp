//
//  FavoritesViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 16/12/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Alamofire

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var favArray = [Pokemon]()
    let themeDefault = UserDefaults.standard
    
    @IBOutlet weak var favTableView: UITableView!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the cell height
        self.favTableView.rowHeight = 101.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check is dark mode is enabled
        let darkSwitch = themeDefault.bool(forKey: "themeDefault")
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch == true {
            darkTheme()
            // table view separator color
            favTableView.separatorColor = Constants.Colors.gray40
        } else {
            lightTheme()
            // table view separator color
            favTableView.separatorColor = UIColor.lightGray
        }
        
        // check favArray
        if let data = themeDefault.value(forKey:"FavPokemon") as? Data {
            favArray = try! PropertyListDecoder().decode([Pokemon].self, from: data)
        }
        title = "\(favArray.count) favorites"
        if favArray.count <= 1 {
            sortButton.isEnabled = false
        }
        
        favTableView.reloadData()
    }
    
    @IBAction func sortPokemon(_ sender: Any) {
        // setup an action sheet and its title
        let actionSheet = UIAlertController(title: "Choose a way to sort your favorites", message: nil, preferredStyle: .actionSheet)
        // then we add a cancel button and our sorting options
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Sort by ID number", style: .default) { action in
            // sort pokémon by id number
            self.favArray = self.favArray.sorted { $0.id < $1.id }
            self.sortButton.title = "Sorting by ID"
            // save updated favArray
            self.themeDefault.set(try? PropertyListEncoder().encode(self.favArray), forKey:"FavPokemon")
            self.favTableView.reloadData()
        })
        actionSheet.addAction(UIAlertAction(title: "Sort by ID reversed", style: .default) { action in
            // sort pokémon by id number
            self.favArray = self.favArray.sorted { $0.id > $1.id }
            self.sortButton.title = "Sorting by ID reversed"
            // save updated favArray
            self.themeDefault.set(try? PropertyListEncoder().encode(self.favArray), forKey:"FavPokemon")
            self.favTableView.reloadData()
        })
        actionSheet.addAction(UIAlertAction(title: "Sort A-Z", style: .default) { action in
            // sort pokémon alphabetically
            self.favArray = self.favArray.sorted { $0.name < $1.name }
            self.sortButton.title = "Sorting A-Z"
            // save updated favArray
            self.themeDefault.set(try? PropertyListEncoder().encode(self.favArray), forKey:"FavPokemon")
            self.favTableView.reloadData()
        })
        actionSheet.addAction(UIAlertAction(title: "Sort Z-A", style: .default) { action in
            // sort pokémon "un-alphabetically"
            self.favArray = self.favArray.sorted { $0.name > $1.name }
            self.sortButton.title = "Sorting Z-A"
            // save updated favArray
            self.themeDefault.set(try? PropertyListEncoder().encode(self.favArray), forKey:"FavPokemon")
            self.favTableView.reloadData()
        })
        actionSheet.addAction(UIAlertAction(title: "Sort Randomly 👻", style: .default) { action in
            // sort pokémon randomly
            self.favArray = self.favArray.shuffled()
            self.sortButton.title = "Sorting Randomly"
            // save updated favArray
            self.themeDefault.set(try? PropertyListEncoder().encode(self.favArray), forKey:"FavPokemon")
            self.favTableView.reloadData()
        })
        present(actionSheet, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = themeDefault.value(forKey:"FavPokemon") as? Data {
            favArray = try! PropertyListDecoder().decode([Pokemon].self, from: data)
        }
        return favArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell" , for: indexPath) as! FavTableViewCell
        
        let customSelectedCellColor = UIView()
        // change background color and labels' color to match the app theme
        let darkSwitch = themeDefault.bool(forKey: "themeDefault")
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
        let favPoke: Pokemon
        favPoke = favArray[indexPath.item]
        cell.setPokeCell(favPoke: favPoke)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove from favorite") { (action, view, completion) in
            // remove pokémon from favArray
            self.favArray.remove(at: indexPath.row)
            // save updated favArray
            self.themeDefault.set(try? PropertyListEncoder().encode(self.favArray), forKey:"FavPokemon")
            // delete row
            self.favTableView.deleteRows(at: [indexPath], with: .automatic)
            // update title
            self.title = "\(self.favArray.count) favorites"
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check if it is the right destination View Controller
        if let detailPokemon = segue.destination as? PokeInfoController {
            // get selected cell
            if let cell = sender as? UITableViewCell {
                // get its index
                let indexPath = favTableView.indexPath(for: cell)
                // get pokemon object at that index
                let selectedPokemon: Pokemon
                selectedPokemon = favArray[indexPath!.item]
                // send the pokemon selected to the destination View Controller
                detailPokemon.selectedPokemon = selectedPokemon
            }
        }
    }
}

class FavTableViewCell: UITableViewCell {
    
    @IBOutlet weak var spriteImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    func setPokeCell(favPoke: Pokemon) {
        // setting name label with pokemon name and id label with pokemon id
        nameLabel.text = favPoke.name
        idLabel.text = "\(favPoke.id)"
        // adjusting pokémon name if too long to fit
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.lineBreakMode = .byClipping
        
        // setting detail label with types
        if favPoke.types != nil {
            detailLabel.text = favPoke.types
        } else {
            Alamofire.request(favPoke.url).responseJSON { response in
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
        }
        
        // setting image
        let placeholderImage: UIImage = UIImage(named: "Placeholder")!
        spriteImage.image = placeholderImage
        
        let frontSprite = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(favPoke.id).png"
        // get and display the sprite from the image link + the pokemon id
        Alamofire.request(frontSprite).responseImage { response in
            if let img = response.result.value {
                self.spriteImage.image = img
            }
        }
    }
    
}
