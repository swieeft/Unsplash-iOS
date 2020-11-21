//
//  MyViewController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/21.
//

import UIKit

class MyViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var popupView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.layer.cornerRadius = 16
        popupView.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeAction(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        backgroundView.isUserInteractionEnabled = true
    }
    
    @IBAction func blogButtonAction(_ sender: Any) {
        guard let url = URL(string: "https://swieeft.github.io/") else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func githubButtonAction(_ sender: Any) {
        guard let url = URL(string: "https://github.com/swieeft") else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func closeAction(_ gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}
