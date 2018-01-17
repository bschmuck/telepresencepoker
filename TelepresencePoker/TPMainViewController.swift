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
    
    
    @IBOutlet weak var potLabel: UILabel!
    @IBOutlet weak var chipsLabel: UILabel!
    @IBOutlet weak var handCard1: UIImageView!
    @IBOutlet weak var handCard2: UIImageView!
    @IBOutlet weak var handCard3: UIImageView!
    @IBOutlet weak var handCard4: UIImageView!
    @IBOutlet weak var handCard5: UIImageView!
    
    @IBOutlet weak var tableCard1: UIImageView!
    @IBOutlet weak var tableCard2: UIImageView!
    @IBOutlet weak var tableCard3: UIImageView!
    @IBOutlet weak var tableCard4: UIImageView!
    @IBOutlet weak var tableCard5: UIImageView!
    
    let stateManager = TPGameState()
    
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateGameState), name: NSNotification.Name(rawValue: "GameStateDidUpdate"), object: nil)
        
        stateManager.getGameState()
    }
    
    @objc func updateGameState(notification: Notification) {
        DispatchQueue.main.async {
            self.chipsLabel.text = "$\(self.stateManager.chips)"
            self.potLabel.text = "$\(self.stateManager.pot)"
            self.betButton.setTitle("Bet $\(self.stateManager.bet)", for: .normal)
            if self.raiseVal < self.stateManager.bet {
                self.raiseVal = self.stateManager.bet
                self.raiseLabel.text = "$\(self.raiseVal)"
            }
            
            
            let hand = self.stateManager.hand
            if hand.count > 0 {
                let imageName = "\(hand[0]["suit"]!)_\(hand[0]["rank"]!)"
                self.handCard1.image = UIImage(named: "\(imageName)")
                self.handCard1.isHidden = false
            } else {
                self.handCard1.isHidden = true
            }
            if hand.count > 1 {
                self.handCard2.image = UIImage(named: "\(hand[1]["suit"]!)_\(hand[1]["rank"]!)")
                self.handCard2.isHidden = false
            } else {
                self.handCard2.isHidden = true
            }
            if hand.count > 2 {
                self.handCard3.image = UIImage(named: "\(hand[2]["suit"]!)_\(hand[2]["rank"]!)")
                self.handCard3.isHidden = false
            } else {
                self.handCard3.isHidden = true
            }
            if hand.count > 3 {
                self.handCard4.image = UIImage(named: "\(hand[3]["suit"]!)_\(hand[3]["rank"]!)")
                self.handCard4.isHidden = false
            } else {
                self.handCard4.isHidden = true
            }
            if hand.count > 4 {
                self.handCard5.image = UIImage(named: "\(hand[4]["suit"]!)_\(hand[4]["rank"]!)")
                self.handCard5.isHidden = false
            } else {
                self.handCard5.isHidden = true
            }
            
            let table = self.stateManager.table
            if table.count > 0 {
                self.tableCard1.image = UIImage(named: "\(table[0]["suit"]!)_\(table[0]["rank"]!)")
                self.tableCard1.isHidden = false
            } else {
                self.tableCard1.isHidden = true
            }
            if table.count > 1 {
                self.tableCard2.image = UIImage(named: "\(table[1]["suit"]!)_\(table[1]["rank"]!)")
                self.tableCard2.isHidden = false
            } else {
                self.tableCard2.isHidden = true
            }
            if table.count > 2 {
                self.tableCard3.image = UIImage(named: "\(table[2]["suit"]!)_\(table[2]["rank"]!)")
                self.tableCard3.isHidden = false
            } else {
                self.tableCard3.isHidden = true
            }
            if table.count > 3 {
                self.tableCard4.image = UIImage(named: "\(table[3]["suit"]!)_\(table[3]["rank"]!)")
                self.tableCard4.isHidden = false
            } else {
                self.tableCard4.isHidden = true
            }
            if table.count > 4 {
                self.tableCard5.image = UIImage(named: "\(table[4]["suit"]!)_\(table[4]["rank"]!)")
                self.tableCard5.isHidden = false
            } else {
                self.tableCard5.isHidden = true
            }
        }
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
        if raiseVal >= self.stateManager.bet + 10 {
            raiseVal -= 10
        }
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
