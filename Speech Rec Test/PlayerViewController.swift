//
//  PlayerViewController.swift
//  Speech Rec Test
//
//  Created by Gregorius Albert on 11/06/22.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    var player:AVAudioPlayer?
    var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initAudio()
    }
    
    func initAudio() -> Void {
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = path.appendingPathComponent("recording.m4a") // URL
        
        do {
            player = try AVAudioPlayer(contentsOf: filename)
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func play(_ sender: UIButton) {
        
        if !isPlaying {
            isPlaying = true
            guard let player = player else { return }
            player.play()
            sender.setTitle("Pause", for: .normal)
        } else {
            isPlaying = false
            guard let player = player else { return }
            player.pause()
            sender.setTitle("Play", for: .normal)
        }
        
    }
    
}
