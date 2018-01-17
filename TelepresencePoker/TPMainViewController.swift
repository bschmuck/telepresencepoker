//
//  TPMainViewController.swift
//  TelepresencePoker
//
//  Created by Brandon Schmuck on 1/16/18.
//  Copyright © 2018 Brandon Schmuck. All rights reserved.
//

import UIKit

class TPMainViewController: UIViewController {

    @IBOutlet weak var betButton: UIButton!
    @IBOutlet weak var raiseButton: UIButton!
    @IBOutlet weak var foldButton: UIButton!
    
    @IBOutlet weak var decButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var raiseView: UIView!
    @IBOutlet weak var raiseLabel: UILabel!
    @IBOutlet weak var handView: UIView!
    
    var raiseVal = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        raiseButton.layer.cornerRadius = 15
        betButton.layer.cornerRadius = 15
        foldButton.layer.cornerRadius = 15
        raiseView.layer.cornerRadius = 15
        raiseView.isHidden = true
        
        decButton.addTarget(self, action: #selector(decRaise), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(incRaise), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(hideRaiseView), for: .touchUpInside)
        raiseButton.addTarget(self, action: #selector(showRaiseView), for: .touchUpInside)
        handView.layer.cornerRadius = 15
    }
    
    @objc func showRaiseView() {
        UIView.animate(withDuration: 0.2) {
            self.raiseView.isHidden = false
        }
    }
    
    @objc func hideRaiseView() {
        UIView.animate(withDuration: 0.2) {
            self.raiseView.isHidden = true
        }
    }
    
    @objc func incRaise() {
        raiseVal += 10
        DispatchQueue.main.async {
            self.raiseLabel.text = "$\(self.raiseVal)"
        }
    }
    
    @objc func decRaise() {
        raiseVal -= 10
        DispatchQueue.main.async {
            self.raiseLabel.text = "$\(self.raiseVal)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
