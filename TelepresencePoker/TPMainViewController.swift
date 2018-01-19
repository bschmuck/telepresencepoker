//
//  TPMainViewController.swift
//  TelepresencePoker
//
//  Created by Brandon Schmuck on 1/16/18.
//  Copyright © 2018 Brandon Schmuck. All rights reserved.
//

import UIKit
import TwilioVideo

class TPMainViewController: UIViewController {
    
    struct PlatformUtils {
        static let isSimulator: Bool = {
            var isSim = false
            #if arch(i386) || arch(x86_64)
                isSim = true
            #endif
            return isSim
        }()
    }
    
    // Client Identity is "player_iphone"
    var player_iphone_accessToken: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJqdGkiOiJTS2RlZTM4YmU3MGVhOTllMTA5MzE1MzRkODdkZTRlNmNlLTE1MTYzMzY5MTkiLCJpc3MiOiJTS2RlZTM4YmU3MGVhOTllMTA5MzE1MzRkODdkZTRlNmNlIiwic3ViIjoiQUNjMWYzNWQzNzQzYzA5MjIwMWM5ZTUyN2MyMTM3Y2QxNSIsImV4cCI6MTUxNjM0MDUxOSwiZ3JhbnRzIjp7ImlkZW50aXR5IjoicGxheWVyX2lwaG9uZSIsInZpZGVvIjp7fX19.znKR8d9DXzll6J-h12U97QadHYYGHOlrsHxS9ubYuBo"
    
    var board_ipad_accessToken: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJqdGkiOiJTS2RlZTM4YmU3MGVhOTllMTA5MzE1MzRkODdkZTRlNmNlLTE1MTYzMzY5MzYiLCJpc3MiOiJTS2RlZTM4YmU3MGVhOTllMTA5MzE1MzRkODdkZTRlNmNlIiwic3ViIjoiQUNjMWYzNWQzNzQzYzA5MjIwMWM5ZTUyN2MyMTM3Y2QxNSIsImV4cCI6MTUxNjM0MDUzNiwiZ3JhbnRzIjp7ImlkZW50aXR5IjoiYm9hcmRfaXBhZCIsInZpZGVvIjp7fX19.TvQelxpI5ywa_k2UDieWJRr7BhLOi3hizOmAVXGBYVU"
    
    
    // Video SDK components
    var room: TVIRoom?
    var camera: TVICameraCapturer?
    var localVideoTrack: TVILocalVideoTrack?
    var localAudioTrack: TVILocalAudioTrack?
    var participant: TVIParticipant?
    var remoteView: TVIVideoView?
    
    // UI Element Outlets and handles
    @IBOutlet weak var previewView: TVIVideoView!
    
    


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
    
    @IBOutlet weak var rotateSlider: UISlider!
    
    @IBOutlet weak var headerView: UIView!
    
    let stateManager = TPGameState()
    
    
    var raiseVal = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PlatformUtils.isSimulator {
            // Do nothing
        } else {
            self.startPreview()
        }
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
    
    func startPreview() {
        if PlatformUtils.isSimulator {
            return
        }
        
        // Preview our local camera track in the local video preview view.
        camera = TVICameraCapturer(source: .frontCamera, delegate: self)
        localVideoTrack = TVILocalVideoTrack.init(capturer: camera!)
        if (localVideoTrack == nil) {
            print("Failed to create video track")
        } else {
            // Add renderer to video track for local preview
            localVideoTrack!.addRenderer(self.previewView)
            
            print("Video track created")
            
            // We will flip camera on tap.
            //let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.flipCamera))
            //self.previewView.addGestureRecognizer(tap)
        }
    }
    
    func setupRemoteVideoView() {
        // Creating `TVIVideoView` programmatically
        self.remoteView = TVIVideoView.init(frame: CGRect.zero, delegate:self)
    
        
        self.view.insertSubview(self.remoteView!, at: 0)
        
        
        // `TVIVideoView` supports scaleToFill, scaleAspectFill and scaleAspectFit
        // scaleAspectFit is the default mode when you create `TVIVideoView` programmatically.
        self.remoteView!.contentMode = .scaleAspectFit;
        
        let centerX = NSLayoutConstraint(item: self.remoteView!,
                                         attribute: NSLayoutAttribute.centerX,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutAttribute.centerX,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerX)
        let centerY = NSLayoutConstraint(item: self.remoteView!,
                                         attribute: NSLayoutAttribute.centerY,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutAttribute.centerY,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerY)
        let width = NSLayoutConstraint(item: self.remoteView!,
                                       attribute: NSLayoutAttribute.width,
                                       relatedBy: NSLayoutRelation.equal,
                                       toItem: self.view,
                                       attribute: NSLayoutAttribute.width,
                                       multiplier: 1,
                                       constant: 0);
        self.view.addConstraint(width)
        let height = NSLayoutConstraint(item: self.remoteView!,
                                        attribute: NSLayoutAttribute.height,
                                        relatedBy: NSLayoutRelation.equal,
                                        toItem: self.view,
                                        attribute: NSLayoutAttribute.height,
                                        multiplier: 1,
                                        constant: 0);
        self.view.addConstraint(height)
        
    }
    
    func connectChat(accessToken: String) {
        self.prepareLocalMedia()
        
        // Preparing the connect options with the access token that we fetched (or hardcoded).
        let connectOptions = TVIConnectOptions.init(token: accessToken) { (builder) in
            
            // Use the local media that we prepared earlier.
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [TVILocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [TVILocalVideoTrack]()
            
            // The name of the Room where the Client will attempt to connect to. Please note that if you pass an empty
            // Room `name`, the Client will create one for you. You can get the name or sid from any connected Room.
            builder.roomName = "TEST_ROOM"//self.roomTextField.text
        }
        
        // Connect to the Room using the options we provided.
        room = TwilioVideo.connect(with: connectOptions, delegate: self)
        
        print("Attempting to connect to room \(String(describing: "TEST_ROOM"))")
    }

    @IBAction func pressedStartChat(_ sender: Any) {
        connectChat(accessToken: board_ipad_accessToken)
        
        betButton.isHidden = true
        raiseButton.isHidden = true
        foldButton.isHidden = true
        handView.isHidden = true
        rotateSlider.isHidden = true
        
        headerView.isHidden = true
        raiseLabel.isHidden = true
        
    }
    
    @IBAction func pressedStartRemote(_ sender: Any) {
        connectChat(accessToken: player_iphone_accessToken)
    }
    
    @IBAction func stoppedSlidingSlider(_ sender: Any) {
        print("Ended sliding here")
    }
    
    func prepareLocalMedia() {
        
        // We will share local audio and video when we connect to the Room.
        // Create an audio track.
        if (localAudioTrack == nil) {
            localAudioTrack = TVILocalAudioTrack.init()
            
            if (localAudioTrack == nil) {
                print("Failed to create audio track")
            }
        }
        
        // Create a video track which captures from the camera.
        if (localVideoTrack == nil) {
            self.startPreview()
        }
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
    
}

// MARK: TVIRoomDelegate
extension TPMainViewController : TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        
        // At the moment, this example only supports rendering one Participant at a time.
        
        print("Connected to room \(room.name) as \(String(describing: room.localParticipant?.identity))")
        
        if (room.participants.count > 0) {
            self.participant = room.participants[0]
            self.participant?.delegate = self
        }
    }
    
    func room(_ room: TVIRoom, didDisconnectWithError error: Error?) {
        print("Disconncted from room \(room.name), error = \(String(describing: error))")
        
        //        self.cleanupRemoteParticipant()
        self.room = nil
        
        //        self.showRoomUI(inRoom: false)
    }
    
    func room(_ room: TVIRoom, didFailToConnectWithError error: Error) {
        print("Failed to connect to room with error")
        self.room = nil
        print(error.localizedDescription)
        
        //        self.showRoomUI(inRoom: false)
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIParticipant) {
        if (self.participant == nil) {
            self.participant = participant
            self.participant?.delegate = self
        }
        print("Room \(room.name), Participant \(participant.identity) connected")
    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIParticipant) {
        if (self.participant == participant) {
            //            cleanupRemoteParticipant()
        }
        print("Room \(room.name), Participant \(participant.identity) disconnected")
    }
}

// MARK: TVIParticipantDelegate
extension TPMainViewController : TVIParticipantDelegate {
    func participant(_ participant: TVIParticipant, addedVideoTrack videoTrack: TVIVideoTrack) {
        print("Participant \(participant.identity) added video track")
        
        if (self.participant == participant) {
            setupRemoteVideoView()
            videoTrack.addRenderer(self.remoteView!)
        }
    }
    
    func participant(_ participant: TVIParticipant, removedVideoTrack videoTrack: TVIVideoTrack) {
        print("Participant \(participant.identity) removed video track")
        
        if (self.participant == participant) {
            videoTrack.removeRenderer(self.remoteView!)
            self.remoteView?.removeFromSuperview()
            self.remoteView = nil
        }
    }
    
    func participant(_ participant: TVIParticipant, addedAudioTrack audioTrack: TVIAudioTrack) {
        print("Participant \(participant.identity) added audio track")
        
    }
    
    func participant(_ participant: TVIParticipant, removedAudioTrack audioTrack: TVIAudioTrack) {
        print("Participant \(participant.identity) removed audio track")
    }
    
    func participant(_ participant: TVIParticipant, enabledTrack track: TVITrack) {
        var type = ""
        if (track is TVIVideoTrack) {
            type = "video"
        } else {
            type = "audio"
        }
        print("Participant \(participant.identity) enabled \(type) track")
    }
    
    func participant(_ participant: TVIParticipant, disabledTrack track: TVITrack) {
        var type = ""
        if (track is TVIVideoTrack) {
            type = "video"
        } else {
            type = "audio"
        }
        print("Participant \(participant.identity) disabled \(type) track")
    }
}




extension TPMainViewController : TVIVideoViewDelegate {
    func videoView(_ view: TVIVideoView, videoDimensionsDidChange dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
        print("CHANGED DIMENSIONS")
    }
}

// MARK: TVICameraCapturerDelegate
extension TPMainViewController : TVICameraCapturerDelegate {
    func cameraCapturer(_ capturer: TVICameraCapturer, didStartWith source: TVICameraCaptureSource) {
        self.previewView.shouldMirror = (source == .frontCamera)
    }
}


