//
//  AKChatViewController.swift
//  WoundCare
//
//  Created by Ashwin Kumar on 7/21/19.
//  Copyright © 2019 Ashwin Kumar. All rights reserved.
//

import Foundation
import UIKit

class AKChatViewController: UIViewController, UINavigationControllerDelegate {
    
    var thumbnailImage: UIImage!
    
    @IBOutlet weak var chatMessageBackground: SpringImageView!
    @IBOutlet weak var chatBackView: SpringImageView!
    
    @IBOutlet weak var thumbnailImageView: SpringImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        thumbnailImageView.image = thumbnailImage
        thumbnailImageView.isHidden = true
        chatMessageBackground.isHidden = true
        chatBackView.isHidden = true
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        thumbnailImageView.isHidden = false
        thumbnailImageView.curve = "easeIn"
        thumbnailImageView.animation = "slideLeft"
        thumbnailImageView.duration = 2.0
//        thumbnailImageView.delay = 2.0
        
        chatMessageBackground.isHidden = false
        chatMessageBackground.curve = "easeIn"
        chatMessageBackground.animation = "slideLeft"
        chatMessageBackground.duration = 2.0
        
        
        chatMessageBackground.animate()
        thumbnailImageView.animate()
    }
    
    
    @IBAction func chatBack(_ sender: Any) {
        chatBackView.isHidden = false
        chatBackView.curve = "easeIn"
        chatBackView.animation = "slideRight"
        chatBackView.duration = 2.0
        chatBackView.animate()
    }
    
}





