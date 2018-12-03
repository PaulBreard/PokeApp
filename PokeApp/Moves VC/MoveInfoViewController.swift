//
//  MoveInfoViewController.swift
//  PokeApp
//
//  Created by Paul BREARD on 31/10/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Alamofire

class MoveInfoViewController: UIViewController {

    @IBOutlet weak var pokeMoveNameLabel: UILabel!
    @IBOutlet weak var pokeMoveInfoView: UIView!
    @IBOutlet weak var damageClassLabel: UILabel!
    @IBOutlet weak var moveTypeLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var movePowerPointsLabel: UILabel!
    @IBOutlet weak var movePowerLabel: UILabel!
    @IBOutlet weak var pokeMoveEffectLabel: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var selectedMove: Moves!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // display move name in a label and the Navigation Bar title
        pokeMoveNameLabel.text = selectedMove.name
        self.title = selectedMove.name
        // adjusts font size of the name in the label to fit in the view if too long
        pokeMoveNameLabel.adjustsFontSizeToFitWidth = true
        pokeMoveNameLabel.lineBreakMode = .byClipping
        
        loadMoveDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check from if dark theme is enabled
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        
        // if dark theme is enabled, app theme will be dark, else it will be light
        if darkSwitch == true {
            darkTheme()
            darkThemePokeMove()
        } else {
            lightTheme()
            lightThemePokeMove()
        }
    }
    
    func darkThemePokeMove() {
        pokeMoveNameLabel.textColor = UIColor.white
        damageClassLabel.textColor = UIColor.white
        moveTypeLabel.textColor = UIColor.white
        accuracyLabel.textColor = UIColor.white
        movePowerPointsLabel.textColor = UIColor.white
        movePowerLabel.textColor = UIColor.white
        pokeMoveEffectLabel.textColor = UIColor.white
        
        // activity indicator
        activityIndicator.color = UIColor.white
        loadingLabel.textColor = UIColor.white
        
        pokeMoveInfoView.backgroundColor = Constants.Colors.gray40
    }
    
    func lightThemePokeMove() {
        pokeMoveNameLabel.textColor = UIColor.black
        damageClassLabel.textColor = UIColor.black
        moveTypeLabel.textColor = UIColor.black
        accuracyLabel.textColor = UIColor.black
        movePowerPointsLabel.textColor = UIColor.black
        movePowerLabel.textColor = UIColor.black
        pokeMoveEffectLabel.textColor = UIColor.black
        
        // activity indicator
        activityIndicator.color = UIColor.black
        loadingLabel.textColor = UIColor.black
        
        pokeMoveInfoView.backgroundColor = UIColor.white
    }
    
    private func loadMoveDetails() {
        // start activity indicator
        activityIndicator.startAnimating()
        // blur overlay while loading data
        let darkSwitch = Constants.Settings.themeDefault.bool(forKey: "themeDefault")
        if !UIAccessibility.isReduceTransparencyEnabled {
            self.blurView.backgroundColor = .clear
            if darkSwitch == true {
                let blurEffect = UIBlurEffect(style: .dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                // always fill the view
                blurEffectView.frame = self.blurView.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.blurView.addSubview(blurEffectView)
            } else {
                let blurEffect = UIBlurEffect(style: .light)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                // always fill the view
                blurEffectView.frame = self.blurView.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.blurView.addSubview(blurEffectView)
            }
        } else {
            if darkSwitch == true {
                self.blurView.backgroundColor = Constants.Colors.gray28
            } else {
                self.blurView.backgroundColor = .white
            }
        }
        
        // get the move's details from the url of the selected move
        Alamofire.request(selectedMove.url).responseJSON { response in
            if let jsonDict = response.result.value as? [String: Any] {
                
                // set the move details and the move effect from jsonDict
                self.selectedMove.setMoveDetails(jsonObject: jsonDict)
                self.selectedMove.setMoveEffect(jsonObject: jsonDict)
                
                // display damage class, type, accuracy percentage, power points number and power score
                self.damageClassLabel.attributedText = self.attributedText(withString: String(format: "Damage Class: %@", self.selectedMove.damage!), regularString: self.selectedMove.damage!, font: self.damageClassLabel.font)
                
                self.moveTypeLabel.attributedText = self.attributedText(withString: String(format: "Type: %@", self.selectedMove.type!), regularString: self.selectedMove.type!, font: self.moveTypeLabel.font)
                
                 self.accuracyLabel.attributedText = self.attributedText(withString: String(format: "Accuracy: %@", self.selectedMove.accuracy!), regularString: self.selectedMove.accuracy!, font: self.accuracyLabel.font)
                
                self.movePowerPointsLabel.attributedText = self.attributedText(withString: String(format: "Power Points: %@", self.selectedMove.powerPoints!), regularString: self.selectedMove.powerPoints!, font: self.movePowerPointsLabel.font)
                
                self.movePowerLabel.attributedText = self.attributedText(withString: String(format: "Power: %@", self.selectedMove.power!), regularString: self.selectedMove.power!, font: self.movePowerLabel.font)
                
                // display the move's effect with its chance
                self.pokeMoveEffectLabel.text = self.selectedMove.effect!
                // wrap text and set number of lines
                self.pokeMoveEffectLabel.lineBreakMode = .byWordWrapping
                self.pokeMoveEffectLabel.numberOfLines = 0
                
                // stop activity indicator
                self.activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.6, animations: {
                    self.blurView.alpha = 0.0
                    self.loadingLabel.isHidden = true
                })
            }
        }
    }
}
