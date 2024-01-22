//
//  UIView+Extensions.swift
//  Tracker
//
//  Created by Bogdan Fartdinov on 16.01.2024.
//

import UIKit

extension UIView {
    
    func addHideKeyboardTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    var topSuperview: UIView? {
        var view = superview
        while view?.superview != nil {
            view = view!.superview
        }
        return view
    }
    
    @objc func dismissKeyboard() {
        topSuperview?.endEditing(true)
    }
}
