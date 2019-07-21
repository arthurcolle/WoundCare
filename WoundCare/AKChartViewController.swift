//
//  AKChartViewController.swift
//  WoundCare
//
//  Created by Ashwin Kumar on 7/20/19.
//  Copyright © 2019 Ashwin Kumar. All rights reserved.
//

import Foundation
import UIKit
import CircleMenu


extension UIColor {
    static func color(red: Int, green: Int, blue: Int, alpha: Float) -> UIColor {
        return UIColor(
            red: 1.0 / 255.0 * CGFloat(red),
            green: 1.0 / 255.0 * CGFloat(green),
            blue: 1.0 / 255.0 * CGFloat(blue),
            alpha: CGFloat(alpha))
    }
}


class AKChartViewController: UIViewController, CircleMenuDelegate {
    let items: [(icon: String, color: UIColor)] = [
        
        ("cameraicon3", UIColor(red: 0.07, green: 0.78, blue: 0.61, alpha: 1)),
        ("notifications-btn", UIColor(red: 0.61, green: 0.83, blue: 0.94, alpha: 1)),
        ("settings-btn", UIColor(red: 0.53, green: 0.60, blue: 0.68, alpha: 1)),
        ("icon_home", UIColor(red: 0.98, green: 0.725, blue: 0.545, alpha: 1)),
//        ("nearby-btn", UIColor(red: 1, green: 0.39, blue: 0, alpha: 1))
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = CircleMenu(
            frame: CGRect(x: 157, y: 669, width: 60, height: 60),
            normalIcon:"icon_menu",
            selectedIcon:"icon_close",
            buttonsCount: 4,
            duration: 1.5,
            distance: 100)
        button.backgroundColor = UIColor.lightGray
        button.delegate = self
        button.layer.cornerRadius = button.frame.size.width / 2.0
        view.addSubview(button)
    }
    
    func circleMenu(_: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = items[atIndex].color
        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
        let highlightedImage = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(_: CircleMenu, buttonWillSelected _: UIButton, atIndex: Int) {
        print("button will selected: \(atIndex)")
    }
    
    func circleMenu(_: CircleMenu, buttonDidSelected _: UIButton, atIndex: Int) {
        print("button did selected: \(atIndex)")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "cameraViewController")
        self.present(secondViewController, animated: true, completion: nil)
        
    }
    
}
