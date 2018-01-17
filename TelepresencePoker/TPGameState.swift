//
//  TPGameState.swift
//  TelepresencePoker
//
//  Created by Brandon Schmuck on 1/17/18.
//  Copyright © 2018 Brandon Schmuck. All rights reserved.
//

import UIKit

class TPGameState: NSObject {
    var chips = 0
    var pot = 0
    var hand = [[String :  String]]()
    var table = [[String :  String]]()
    var bet = 0
    
    func getGameState() {
        let url = URL(string: "https://telepresencepoker.herokuapp.com/state")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data!, options:.mutableLeaves) as? NSDictionary
                let state = jsonResponse!["state"] as! NSDictionary;
                self.chips = state["chips"] as! Int
                self.pot = state["pot"] as! Int
                self.hand = state["hand"] as! [[String :  String]]
                self.table = state["table"] as! [[String: String]]
                self.bet = state["bet"] as! Int
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GameStateDidUpdate"), object: nil)
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
}
