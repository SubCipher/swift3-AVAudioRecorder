//
//  ViewController.swift
//  Swift3AvAudioRecorder
//
//  Created by knax on 11/29/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var recordButtonOutlet: UIButton!
    @IBOutlet weak var recordedViewOutlet: UIView!
    @IBOutlet weak var statusLabelOutlet: UILabel!
    @IBOutlet weak var timerLabelOutlet: UILabel!
    @IBOutlet weak var startRecordingOutlet: UIButton!
    
    
    var waveAnimationView:UIView!
    var nonObservablePropertiesUpdateTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
       self.buildVoiceCircle()
    }
    @IBAction func startRecordingButtonAction(_ sender: UIButton){
        
        if AudioRecordManager.shared.recorded(fileName: "TestFile") {
            nonObservablePropertiesUpdateTimer.resume()
        }
        
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.includesApproximationPhrase = false
        formatter.includesTimeRemainingPhrase = false
        formatter.allowedUnits = [.minute,.second]
        formatter.calendar = Calendar.current
        
        
        nonObservablePropertiesUpdateTimer.setEventHandler { [weak self ] in
            
            guard let peak = AudioRecordManager.shared.recorder else {
                return
            }
            self?.timerLabelOutlet.text = formatter.string(from: (AudioRecordManager.shared.recorder?.currentTime)!)
            
            let percent = (Double(AudioRecordManager.shared.recorderPeak0) + 160) / 160
            let final = CGFloat(percent) + 0.3
            
            
            UIView.animate(withDuration: 0.15, animations:{
                self?.waveAnimationView.transform = CGAffineTransform(scaleX: final, y: final)
            })
            
            
        }
        nonObservablePropertiesUpdateTimer.schedule(deadline: DispatchTime.now(), repeating: DispatchTimeInterval.milliseconds(100))
        
   
    
        UIView.animate(withDuration: 0.15, animations: {
            self.waveAnimationView.transform = CGAffineTransform(scaleX:1, y:1)
        })
        
        DispatchQueue.main.async {
            self.statusLabelOutlet.text = "Release to stop recording"
            self.statusLabelOutlet.textColor = UIColor.orange
        }
        
        
    }
    
    @IBAction func stopRecordingButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.waveAnimationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        })
        
        nonObservablePropertiesUpdateTimer.suspend()
        
        DispatchQueue.main.async {
            self.statusLabelOutlet.text = "Press and hold to start"
            self.statusLabelOutlet.textColor = UIColor.green
        }
    }
    
    @IBAction func playButtonOutlet(_ sender: Any) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        print("file location",url.path)
        
        if FileManager.default.fileExists(atPath: url.path){
            print("file found")
        } else {
            print("no file found")
        }
    }
    
    
    func buildVoiceCircle(){
        
        let size = CGSize(width: 200, height: 200)
        
        let newPoint = CGPoint(x:self.recordedViewOutlet.frame.size.width / 2 - 100, y: self.recordedViewOutlet.frame.height / 2 - 100)
        waveAnimationView = UIView(frame: CGRect(origin:newPoint, size: size))
        waveAnimationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        waveAnimationView.layer.cornerRadius = 100
        
        waveAnimationView.backgroundColor = UIColor.clear
        waveAnimationView.layer.borderColor = UIColor.green.cgColor
        waveAnimationView.layer.borderWidth = 1.0
        
        self.recordedViewOutlet.addSubview(waveAnimationView)
        self.waveAnimationView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
    }

}

