//
//  LaunchViewController.swift
//  WoundCare
//
//  Created by Ashwin Kumar on 7/20/19.
//  Copyright © 2019 Ashwin Kumar. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    var viewToAnimate = SpringView()
    override func viewDidLoad() {
        super.viewDidLoad()
//        viewToAnimate = SpringView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
//        viewToAnimate.backgroundColor = UIColor.red
//        viewToAnimate.animation = "squeezeLeft"
//        viewToAnimate.curve = "easeIn"
//        viewToAnimate.duration = 2.0
//        viewToAnimate.
//
//        view.addSubview(viewToAnimate)
//        viewToAnimate.animate()
        
    }
    @IBAction func goToChartView(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyBoard.instantiateViewController(withIdentifier: "chartViewController")
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    
    
}

