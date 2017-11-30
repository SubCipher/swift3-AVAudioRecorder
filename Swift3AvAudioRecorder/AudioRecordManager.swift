//
//  AudioRecordManager.swift
//  Swift3AvAudioRecorder
//
//  Created by knax on 11/29/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import Foundation
import AVFoundation

class AudioRecordManager: NSObject {
    
    static let shared = AudioRecordManager()
    
    var recordingSession: AVAudioSession!
    var recorder:AVAudioRecorder?
    
    func setup(){
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission({ (allowed:Bool) in
                if allowed {
                    print("gotit GOOD")
                } else {
                    print("Mic not authorized")
                }
                
            })
        } catch {
            print("failed authorization",error.localizedDescription)
        }
    }
    
    var  meterTimer:Timer?
    var recorderApc0:Float = 0
    var recorderPeak0:Float = 0
    
    func recorded(fileName:String)->Bool {
        
        let url = getUserPath().appendingPathComponent(fileName+".m4a")
        let audioURL = URL.init(fileURLWithPath: url.path)
       
        
        let recordedSettings:[String:Any] = [
            AVFormatIDKey:NSNumber(value: kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey:12000.0,
            AVNumberOfChannelsKey:1,
            AVSampleRateKey:44100.0
        ]
        do {
            recorder = try AVAudioRecorder(url: audioURL,settings: recordedSettings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.prepareToRecord()
            
            recorder?.record()
            
            self.meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block:{ (timer:Timer) in
                
                if let recorder = self.recorder {
                    recorder.updateMeters()
                    self.recorderApc0 = recorder.averagePower(forChannel: 0)
                    self.recorderPeak0 = recorder.peakPower(forChannel: 0)
                }
            
            
            })
            
            return true
        } catch {
            return false
        }
    
    }
    
    func finishRecording(){
        self.recorder?.stop()
        self.meterTimer?.invalidate()
    }
    
    
    func getUserPath()->URL{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}



extension AudioRecordManager: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("did finish recording")
    }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("recording error",error?.localizedDescription ?? "")
        
    }
    
}












