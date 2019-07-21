//
//  ViewController.swift
//  WoundCare
//
//  Created by Ashwin Kumar on 7/19/19.
//  Copyright © 2019 Ashwin Kumar. All rights reserved.
//

import UIKit
import CircleMenu
import SwiftSpinner

extension UIColor {
    static func color(_ red: Int, green: Int, blue: Int, alpha: Float) -> UIColor {
        return UIColor(
            red: 1.0 / 255.0 * CGFloat(red),
            green: 1.0 / 255.0 * CGFloat(green),
            blue: 1.0 / 255.0 * CGFloat(blue),
            alpha: CGFloat(alpha))
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate  {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            
            print("Image not found!")
            
            return
        }
        imageTaker.image = selectedImage
    }
}

class ViewController: UIViewController, CircleMenuDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var theLabel: UILabel!
    
    @IBOutlet weak var imageTaker: UIImageView!
    let items: [(icon: String, color: UIColor)] = [
        ("icon_home", UIColor(red: 0.19, green: 0.57, blue: 1, alpha: 1)),
        ("icon_search", UIColor(red: 0.22, green: 0.74, blue: 0, alpha: 1)),
        ("notifications-btn", UIColor(red: 0.96, green: 0.23, blue: 0.21, alpha: 1)),
        ("settings-btn", UIColor(red: 0.51, green: 0.15, blue: 1, alpha: 1)),
        ("nearby-btn", UIColor(red: 1, green: 0.39, blue: 0, alpha: 1))
    ]
    
    var imagePicker: UIImagePickerController!
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theLabel.isHidden = true
        let myCircleButton = CircleMenu(
            frame: CGRect(x: 100, y: 400, width: 50, height: 50),
            normalIcon:"icon_menu",
            selectedIcon:"icon_close",
            buttonsCount: 5,
            duration: 1.5,
            distance: 100)
        myCircleButton.backgroundColor = UIColor.lightGray
        myCircleButton.delegate = self
        myCircleButton.layer.cornerRadius = myCircleButton.frame.size.width / 2.0
//        view.addSubview(myCircleButton)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChatPage" {
            print("in here")
            let cvc = segue.destination as! AKChatViewController
            let thisImage = self.imageTaker.image
            print(thisImage)
            cvc.thumbnailImage = thisImage
        }
    }
    
    
    // Taking photo stuff
    @IBAction func takeThePhoto(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            selectImageFrom(.photoLibrary)
            return
        }
        print("Selecting from camera")
        selectImageFrom(.camera)
        
        
    }
    
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    //    Circle Menu stuff
    func circleMenu(_: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = items[atIndex].color
        
        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
        
        // set highlited image
        let highlightedImage = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(_: CircleMenu, buttonWillSelected _: UIButton, atIndex: Int) {
        print("button will selected: \(atIndex)")
    }
    
    func circleMenu(_: CircleMenu, buttonDidSelected _: UIButton, atIndex: Int) {
        print("button did selected: \(atIndex)")
    }
    
    
    
    // SEND PIC TO FLASK
    @IBAction func goToChat(_ sender: Any) {
    }
    
    func sendToServer() {
        print("Sending to flask ...")
        
        guard let selectedImage = imageTaker.image else {
            print("Image not found!")
            return
        }
        
        // Resize image here
        let resized_img = selectedImage.resized(withPercentage: 0.4)
        let imageData = resized_img!.jpegData(compressionQuality: 0.5)
        
        
        var url = URL(string: "https://woundcare.ngrok.io/upload_image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let uuid = UUID().uuidString
        let CRLF = "\r\n"
        let fileName = uuid + ".jpg"
        let formName = "file"
        let type = "image/jpeg"     // file type
        let boundary = String(format: "----iOSURLSessionBoundary.%08x%08x", arc4random(), arc4random())
        var body = Data()
        body.append(("--\(boundary)" + CRLF).data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"formName\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append(("Content-Type: \(type)" + CRLF + CRLF).data(using: .utf8)!)
        body.append(imageData as! Data)
        body.append(CRLF.data(using: .utf8)!)
        body.append(("--\(boundary)--" + CRLF).data(using: .utf8)!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        print ("here")
        DispatchQueue.main.async {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    return // check for fundamental networking error
                }
                
                // Getting values from JSON Response
                //                let responseString = String(data: data, encoding: .utf8)
                //                print("responseString = \(String(describing: responseString))")
                print(data)
                
                do {
                    let imageData = data
                    DispatchQueue.main.async {
                        self.imageTaker.image = UIImage(data: imageData)
                    }
                    print("Image obtained!!!")
                    
                    
                    //                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                }catch _ {
                    print ("OOps not good JSON formatted response")
                }
            }
            task.resume()
        }
    
    }
    
    @IBAction func sendToFlask(_ sender: Any) {
        print("Sending to flask ...")
        SwiftSpinner.show("Analyzing Wound...")
        
        guard let selectedImage = imageTaker.image else {
            print("Image not found!")
            return
        }
        
        // Resize image here
        let resized_img = selectedImage.resized(withPercentage: 0.4)
        let imageData = resized_img!.jpegData(compressionQuality: 0.5)
        
        
        var url = URL(string: "https://woundcare.ngrok.io/upload_image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let uuid = UUID().uuidString
        let CRLF = "\r\n"
        let fileName = uuid + ".jpg"
        let formName = "file"
        let type = "image/jpeg"     // file type
        let boundary = String(format: "----iOSURLSessionBoundary.%08x%08x", arc4random(), arc4random())
        var body = Data()
        body.append(("--\(boundary)" + CRLF).data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"formName\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append(("Content-Type: \(type)" + CRLF + CRLF).data(using: .utf8)!)
        body.append(imageData as! Data)
        body.append(CRLF.data(using: .utf8)!)
        body.append(("--\(boundary)--" + CRLF).data(using: .utf8)!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        print ("here")
        DispatchQueue.main.async {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    return // check for fundamental networking error
                }
                
                // Getting values from JSON Response
//                let responseString = String(data: data, encoding: .utf8)
//                print("responseString = \(String(describing: responseString))")
                print(data)
                
                do {
                    let imageData = data
                    DispatchQueue.main.async {
                        self.imageTaker.image = UIImage(data: imageData)
                        SwiftSpinner.hide()
                        self.theLabel.isHidden = false
                        
                    }
                    
                    print("Image obtained!!!")
                    
                    
//                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                }catch _ {
                    
                    // Have default image here
                    print ("OOps not good JSON formatted response")
                    
                    
                    
                    SwiftSpinner.hide()
                }
            }
            task.resume()
        }
    }
    
    
    
    
}

