//
//  Extensions.swift
//  ios18
//
//  Created by Stephan on 30.04.18.
//  Copyright © 2018 mobile. All rights reserved.
//

import UIKit


extension UIViewController {
    
    func hideKeyboardOnTapOutside() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UITextField {
    func error(shakeCount shakes: Float) {
        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = shakes
        shake.autoreverses = false
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(shake, forKey: "position")
    }
}

extension Notification.Name {
    static let add = Notification.Name("add")
    static let delete = Notification.Name("delete")
}
