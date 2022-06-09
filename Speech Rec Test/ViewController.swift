//
//  ViewController.swift
//  Speech Rec Test
//
//  Created by Gregorius Albert on 07/06/22.
//

import UIKit
import Speech
import AVKit

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var languageSelector: UISegmentedControl!
    
    let audioEngine = AVAudioEngine()
    
//    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
//    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "id"))
    var speechRecognizer:SFSpeechRecognizer?
    var recognitionRequest:SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask:SFSpeechRecognitionTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var msg = ""
            
            switch authStatus {
            case .authorized:
                msg = "Transcribe Ready"
                
            case .denied:
                msg = "Speech Recognition permission denied"
                
            case .notDetermined:
                msg = "Speech Recognition not determined"
                
            case .restricted:
                msg = "Speech Recognition restricted"
                
            @unknown default:
                fatalError()
            }
            
            DispatchQueue.main.async {
                self.textLabel.text = msg
            }
        }
    }
    
    
    func startRecording() {
        
        // Clear previous task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio Session Error \n \(error.localizedDescription)")
        }
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Speech Request error")
        }
        
        // MARK: This line defines whether the transcription is live or not
        recognitionRequest.shouldReportPartialResults = true
        
        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            
            if result != nil {
                self.textLabel.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
            
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        self.audioEngine.prepare()
        
        do {
            try self.audioEngine.start()
        }
        catch {
            print("Audio Engine start error \n \(error.localizedDescription)")
        }
        
    }
    
    
    @IBAction func startTranscription(_ sender: UIButton) {
        
        // State is playing, command to stop
        if audioEngine.isRunning {
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            self.startButton.setTitle("Start", for: .normal)
            print("\n\n \(textLabel.text!)")
        }
        
        // State is stopped, command to start
        else {
            self.textLabel.text = ""
            
            // Select the language
            if languageSelector.selectedSegmentIndex == 0 {
                speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
            }
            else if languageSelector.selectedSegmentIndex == 1 {
                speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "id"))
            }
            
            self.startRecording()
            self.startButton.setTitle("Stop", for: .normal)
            
            
            
        }
    }
    
}


