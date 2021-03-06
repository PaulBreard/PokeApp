//
//  Extensions.swift
//  PokeApp
//
//  Created by Paul BREARD on 02/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Foundation

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 10
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        
        // round corners
        layer.cornerRadius = 8
    }
}

extension UIViewController {
    
    func darkTheme() {
        // view background color
        view.backgroundColor = Constants.Colors.gray28
        
        // navigation controller's background style, color and tint color
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = Constants.Colors.gray28
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // tab bar controller's background style, color and tint color
        tabBarController?.tabBar.barStyle = .black
        tabBarController?.tabBar.barTintColor = Constants.Colors.gray28
        tabBarController?.tabBar.tintColor = UIColor.white
        
        // search bar and keyboard
        UISearchBar.appearance().tintColor = UIColor.white
        UITextField.appearance().keyboardAppearance = .dark
    }
    
    func lightTheme() {
        // view background color
        view.backgroundColor = Constants.Colors.light
        
        // navigation controller's background style, color and tint color
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.black
        
        // tab bar controller's background style, color and tint color
        tabBarController?.tabBar.barStyle = .default
        tabBarController?.tabBar.barTintColor = UIColor.white
        tabBarController?.tabBar.tintColor = UIColor.black
        
        // search bar and keyboard
        UISearchBar.appearance().tintColor = UIColor.black
        UITextField.appearance().keyboardAppearance = .light
    }
    
    // attributed string to allow labels to have different styles inside one label
    func attributedText(withString string: String, regularString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: regularString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
}

extension PokeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension MovesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension BerriesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension ItemsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension UIView {
    // enables to apply cornerRadius on a few corners (not on every corner like layer.cornerRadius)
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UIStackView {
    @objc open class func animateVisibilityOfViews(visible: [UIView], hidden: [UIView], duration: TimeInterval = 0.25) {
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [], animations: {
            if !visible.isEmpty {
                addKeyframesForVisibilityOfViews(visible, hidden: false)
            }
            if !hidden.isEmpty {
                addKeyframesForVisibilityOfViews(hidden, hidden: true)
            }
        }, completion: nil)
    }
    
    @objc open class func animateVisibilityOfViews(_ views: [UIView], hidden: Bool, duration: TimeInterval = 0.25) {
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [], animations: {
            addKeyframesForVisibilityOfViews(views, hidden: hidden)
        }, completion: nil)
    }
    
    @objc open class func addKeyframesForVisibilityOfViews(_ views: [UIView], hidden: Bool) {
        UIView.addKeyframe(withRelativeStartTime: hidden ? 0.5 : 0, relativeDuration: 0.5, animations: {
            views.forEach {
                guard $0.isHidden != hidden else { return }
                $0.isHidden = hidden
            }
        })
        UIView.addKeyframe(withRelativeStartTime: hidden ? 0 : 0.5, relativeDuration: 0.5, animations: {
            views.forEach { $0.alpha = hidden ? 0 : 1 }
        })
    }
    
}

