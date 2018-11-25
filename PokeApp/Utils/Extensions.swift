//
//  Extensions.swift
//  PokeApp
//
//  Created by Paul BREARD on 02/11/2018.
//  Copyright © 2018 Paul BREARD. All rights reserved.
//

import UIKit
import Foundation

extension Notification.Name {
    static let darkModeEnabled = Notification.Name("net.sltch.vcoin.notifications.darkModeEnabled")
    static let darkModeDisabled = Notification.Name("net.sltch.vcoin.notifications.darkModeDisabled")
}

//extension UIViewController : UISearchControllerDelegate {
//
//    private func willPresentSearchController(_ searchController: UISearchController) {
//        // update text color
//        searchController.searchBar.textField?.textColor = .white
//    }
//}

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

