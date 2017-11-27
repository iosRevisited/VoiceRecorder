//
//  ViewController.swift
//  VoiceRecorder
//
//  Created by SaiSandeep on 26/11/17.
//  Copyright © 2017 iOSRevisited. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var recordButton = UIButton()
    var playButton = UIButton()
    var isRecording = false
    var audioRecorder: AVAudioRecorder?
    var player : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        // Asking user permission for accessing Microphone
        AVAudioSession.sharedInstance().requestRecordPermission () {
            [unowned self] allowed in
            if allowed {
                // Microphone allowed, do what you like!
                self.setUpUI()
            } else {
                // User denied microphone. Tell them off!
                
            }
        }
    }
    
    // Adding play button and record buuton as subviews
    func setUpUI() {
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recordButton)
        view.addSubview(playButton)
        
        // Adding constraints to Record button
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        let recordButtonHeightConstraint = recordButton.heightAnchor.constraint(equalToConstant: 50)
        recordButtonHeightConstraint.isActive = true
        recordButton.widthAnchor.constraint(equalTo: recordButton.heightAnchor, multiplier: 1.0).isActive = true
        recordButton.setImage(#imageLiteral(resourceName: "record"), for: .normal)
        recordButton.layer.cornerRadius = recordButtonHeightConstraint.constant/2
        recordButton.layer.borderColor = UIColor.white.cgColor
        recordButton.layer.borderWidth = 5.0
        recordButton.imageEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20)
        recordButton.addTarget(self, action: #selector(record(sender:)), for: .touchUpInside)
        
        // Adding constraints to Play button
        playButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor, multiplier: 1.0).isActive = true
        playButton.trailingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: -16).isActive = true
        playButton.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor).isActive = true
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        playButton.addTarget(self, action: #selector(play(sender:)), for: .touchUpInside)
    }
    
    @objc func record(sender: UIButton) {
        if isRecording {
            finishRecording()
        }else {
            startRecording()
        }
    }
    
    @objc func play(sender: UIButton) {
        playSound()
    }
    
    func playSound(){
        let url = getAudioFileUrl()
        
        do {
            // AVAudioPlayer setting up with the saved file URL
            let sound = try AVAudioPlayer(contentsOf: url)
            self.player = sound
            
            // Here conforming to AVAudioPlayerDelegate
            sound.delegate = self
            sound.prepareToPlay()
            sound.play()
            recordButton.isEnabled = false
        } catch {
            print("error loading file")
            // couldn't load file :(
        }
    }
    
    func startRecording() {
        //1. create the session
        let session = AVAudioSession.sharedInstance()
        
        do {
            // 2. configure the session for recording and playback
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try session.setActive(true)
            // 3. set up a high-quality recording session
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            // 4. create the audio recording, and assign ourselves as the delegate
            audioRecorder = try AVAudioRecorder(url: getAudioFileUrl(), settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            //5. Changing record icon to stop icon
            isRecording = true
            recordButton.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
            recordButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
            playButton.isEnabled = false
        }
        catch let error {
            // failed to record!
        }
    }
    
    // Stop recording
    func finishRecording() {
        audioRecorder?.stop()
        isRecording = false
        recordButton.imageEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20)
        recordButton.setImage(#imageLiteral(resourceName: "record"), for: .normal)
    }
    
    // Path for saving/retreiving the audio file
    func getAudioFileUrl() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let audioUrl = docsDirect.appendingPathComponent("recording.m4a")
        return audioUrl
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            finishRecording()
        }else {
            // Recording interrupted by other reasons like call coming, reached time limit.
        }
        playButton.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            
        }else {
            // Playing interrupted by other reasons like call coming, the sound has not finished playing.
        }
        recordButton.isEnabled = true
    }
}



