//
//  PokeMoveViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 31/10/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Alamofire

class PokeMoveViewController: UIViewController {

    @IBOutlet weak var pokeMoveNameLabel: UILabel!
    @IBOutlet weak var damageClassLabel: UILabel!
    @IBOutlet weak var moveTypeLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var movePowerPointsLabel: UILabel!
    @IBOutlet weak var pokeMoveEffectLabel: UILabel!
    @IBOutlet weak var movePowerLabel: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var pokeMoveActivityIndicator: UIActivityIndicatorView!
    
    var selectedMove: PokemonMoves!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // display move name in a label and the Navigation Bar title
        pokeMoveNameLabel.text = selectedMove.moveName
        self.title = selectedMove.moveName
        
        loadMoveDetails()
    }
    
    private func loadMoveDetails() {
        // start activity indicator
        pokeMoveActivityIndicator.startAnimating()
        // blur overlay while loading data
        if !UIAccessibility.isReduceTransparencyEnabled {
            self.blurView.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            // always fill the view
            blurEffectView.frame = self.blurView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blurView.addSubview(blurEffectView)
        } else {
            self.blurView.backgroundColor = .black
        }
        
        // get the move's details from the url of the selected move
        Alamofire.request(selectedMove.moveUrl).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                
                // get the damage class, type, accuracy, power points and power of the move
                guard let damageClassArray = jsonDict["damage_class"] as? [String: String],
                    let damageClass = damageClassArray["name"],
                    let moveTypeArray = jsonDict["type"] as? [String: String],
                    let moveType = moveTypeArray["name"],
                    let moveAccuracy = jsonDict["accuracy"] as? Int? ?? 0,
                    let movePowerPoints = jsonDict["pp"] as? Int,
                    let movePower = jsonDict["power"] as? Int? ?? 0
                else {
                    return
                }
                // display damage class, type, accuracy percentage, power points number and power score
                self.damageClassLabel.text = damageClass.capitalized
                self.moveTypeLabel.text = moveType.capitalized
                self.accuracyLabel.text = "\(moveAccuracy)%"
                self.movePowerPointsLabel.text = "\(movePowerPoints)"
                self.movePowerLabel.text = "\(movePower)"
                
                // get the move's effect dictionary
                guard let moveEffectArray = jsonDict["effect_entries"] as? [[String: Any]]
                    else {
                        return
                }
                // get the effect from the dictionary
                for dic in moveEffectArray {
                    let moveEffect = dic["effect"] as? String
                    
                    // check if the effect's description has a chance variable
                    if moveEffect!.contains("$effect_chance")  {
                        
                        // get the effect chance
                        let effectChance = jsonDict["effect_chance"] as? Int
                        
                        // replace effect chance in the effect description by it's actual chance
                        let moveEffectChance = moveEffect?.replacingOccurrences(of: "$effect_chance", with: "\(effectChance ?? 0)")
                        
                        // display the move's effect with its chance in the VC
                        self.pokeMoveEffectLabel.text = moveEffectChance
                    }
                    else {
                        // display the effect if it doesn't have a chance variable
                        self.pokeMoveEffectLabel.text = moveEffect
                    }
                    // wrap text and set number of lines
                    self.pokeMoveEffectLabel.lineBreakMode = .byWordWrapping
                    self.pokeMoveEffectLabel.numberOfLines = 0
                }
                
                // stop activity indicator
                self.pokeMoveActivityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.6, animations: {
                    self.blurView.alpha = 0.0
                    self.loadingLabel.isHidden = true
                })
            }
        }
    }
    
}
