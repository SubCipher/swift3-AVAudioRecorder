//
//  ViewController.swift
//  SwiftAVAudioRecPlayer
//
//  Created by knax on 11/30/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    var recordingSession:AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var numberOfRecords = 0
    
    
    
    @IBOutlet weak var startRecordingOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingSession = AVAudioSession.sharedInstance()
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("accepted")
            }
        }
    }

    @IBAction func startRecordingAction(_ sender: Any) {
        
        if audioRecorder == nil {
            numberOfRecords += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a)")
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey:12000,
                            AVNumberOfChannelsKey:1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                            ]
            
            //start recording
            
            do {
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                startRecordingOutlet.setTitle("Stop Recording", for: .normal)
                
                
            } catch {
               displayAlert(title: "Recording Failed", message: "Try Again")
            }
            
        }
        else {
            //if audio is in session
            audioRecorder.stop()
            audioRecorder = nil
            
            startRecordingOutlet.setTitle("Start Recording", for: .normal)
        }
    }
    
    func getDirectory()->URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    func displayAlert(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

