//
//  ViewController.swift
//  SwiftWAVPlayer
//
//  Created by Yejin Hong on 2021/07/28.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    var audioPlayer = AVAudioPlayer()
    var audioRecorder = AVAudioRecorder()
    var audioFileURL: URL!
    var isRecording: Bool = false
    
    @IBAction func segmentControl(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            playButton.isHidden = false
            recordButton.isHidden = true
            backwardButton.isHidden = false
            forwardButton.isHidden = false
            recordLabel.isHidden = true
            playLabel.isHidden = false
        case 1:
            playButton.isHidden = true
            recordButton.isHidden = false
            recordButton.isEnabled = false
            backwardButton.isHidden = true
            forwardButton.isHidden = true
            recordLabel.isHidden = false
            playLabel.isHidden = true
            record_Permission()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.isHidden = true
        recordLabel.isHidden = true
    }
    
    //MARK: - 녹음 버튼
    @IBAction func record_Button(_ sender: Any) {
        let button = sender as AnyObject
        
        if audioRecorder.isRecording {
            audioRecorder.stop()
            button.setImage(UIImage(named: "stopRecordButton.png"), for: .normal)
            print("audioRecord Stopped")
        } else {
            record_Start()
            button.setImage(UIImage(named: "recordButton.png"), for: .normal)
        }
    }
    
    //MARK: - 녹음 시작
    func record_Start(){
        do {
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let fileName = UUID().uuidString + ".wav"
            audioFileURL = fileURL.appendingPathComponent(fileName)
            print("audioFileURL = \(audioFileURL!)")
            
            // 8000 16000 32000 44100 48000
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: [AVFormatIDKey: Int(kAudioFormatLinearPCM),
                                                                         AVSampleRateKey: 16000,
                                                                         AVNumberOfChannelsKey: 1,
                                                                         AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue])
            
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            print("end record_Start function")

        } catch (let error) {
            print("record Start Error = \(error)")
        }
    }
    
    //MARK: - 녹음 권한 받아오기
    func record_Permission(){
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            session.requestRecordPermission(){ granted in
                if granted {
                    DispatchQueue.main.async {
                        self.recordButton.isEnabled = true
                    }
                } else {
                    print("Permission does not allowed")
                }
            }
        } catch (let error){
            print("Record Permission Error = \(error)")
        }
    }
  
    
    //MARK: - 재생 버튼
    @IBAction func play_Button(_ sender: Any) {
        let button = sender as AnyObject
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            button.setImage(UIImage(named: "playButtonCircle.png"), for: .normal)
        } else {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL!)
                print("PlayURL = \(audioFileURL!)")
                audioPlayer.delegate = self
            } catch {
                print(error)
            }
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            button.setImage(UIImage(named: "pauseButtonCircle.png"), for: .normal)
        }
    }
}

