//
//  AppInfoViewController.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/21.
//

import UIKit

class AppInfoViewController: UIViewController {
    // MARK : - UI
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var buildLabel: UILabel!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeAction(_:)))
        backgroundView.addGestureRecognizer(tapGesture)
        backgroundView.isUserInteractionEnabled = true
        
        popupView.layer.cornerRadius = 16
        popupView.layer.masksToBounds = true
        
        guard let dictionary = Bundle.main.infoDictionary else {
            return
        }
           
        if let version = dictionary["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version : \(version)"
        }
        
        if let build = dictionary["CFBundleVersion"] as? String {
            buildLabel.text = "Build : \(build)"
        }
    }
    
    // MARK: - Function
    @IBAction func apiProviderButtonAction(_ sender: Any) {
        guard let url = URL(string: "https://unsplash.com/developers") else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func closeAction(_ gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}
