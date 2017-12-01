//
//  ViewController.swift
//  SwiftAVAudioRecPlayer
//
//  Created by knax on 11/30/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var recordingSession:AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var numberOfRecords:Int = 0
    
    var audioPlayer:AVAudioPlayer!
    
    @IBOutlet weak var videoClientTableView: UITableView!
    
    
    @IBOutlet weak var startRecordingOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         recordingSession = AVAudioSession.sharedInstance()
        
//        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int{
//            numberOfRecords = number
//        }
       
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("accepted")
            }
        }
    }
    
    @IBAction func pathCheck(_ sender: Any) {
        
        let path = self.getDirectory()
        
        print("dir path = ",path)
    }
    
    

    @IBAction func startRecordingAction(_ sender: Any) {
        
        if audioRecorder == nil {
            numberOfRecords += 1
            //let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a)")
           
            let recordingName = "fx\(numberOfRecords).m4a"
            let dirPath = getDirectory()
            let pathArray = [dirPath, recordingName]
            let filePath = URL(string: pathArray.joined(separator: "/"))
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey:12000,
                            AVNumberOfChannelsKey:1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                            ]
            
            //start recording
            
            do {
                audioRecorder = try AVAudioRecorder(url: filePath!, settings: settings)
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
            
            UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            videoClientTableView.reloadData()
            
            startRecordingOutlet.setTitle("Start Recording", for: .normal)
        }
    }
    
    
    
    @IBAction func pauseButtonAction(_ sender: Any) {
        
        if audioRecorder.isRecording {
            audioRecorder.pause()
        } else {
            
            audioRecorder.record()
        }
    }
    
    
    
    
    
    func getDirectory()-> String {
        //let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //let documentDirectory = paths[0]
        
         let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] //as String
        
        return dirPath
    }
    
    func displayAlert(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //Table view settings
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of records",numberOfRecords)
        return numberOfRecords
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:indexPath)
        cell.textLabel?.text = String("fx\(indexPath.row + 1).m4a")
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dirPathAsFileURL = URL(fileURLWithPath: getDirectory())
        let path = dirPathAsFileURL.appendingPathComponent("fx\(indexPath.row + 1).m4a")
        
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        } catch {
            print("error",error.localizedDescription)
            print("doc path",path)
        }
    }
    
    
    
    
}

